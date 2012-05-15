# encoding: utf-8
require 'jldrill/spec/storyFunctionality/SampleQuiz'
require 'jldrill/model/quiz/Schedule'
require 'jldrill/model/quiz/Options'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::Version_0_6_1
    module ThinkingTimer
        # Each item also keeps track of the amount of thinking time used
        # in either the review set or forgotten set.  The timer is started
        # from 0 when a problem is created for the item.  The timer is stopped
        # when the item is set correct, incorrect or learned.  If a new
        # item is selected from the quiz without setting the item to
        # correct, incorrect or learned, the thinking time is not changed.
        #
        class MyStory < JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

            def setup(type)
                super(type)
                hasResetQuiz
            end
        end

        Story = MyStory.new("Thinking Timer")

        describe Story.stepName("Keeps track of thinking time") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.quiz.options.promoteThresh = 1
                Story.quiz.options.randomOrder = false
                Story.newSet.length.should_not eql(0)
                Story.newSet[0].should_not be_nil
                @item = Story.newSet[0]
            end

            after(:each) do
                Story.shutdown
            end

            it "should not start the thinking Time for new set items" do
                @item.state.should be_inNewSet
                @item.state.itemStats.thinkingTimer.should_not_receive(:start)
                Story.quiz.createProblem(@item)
            end

            it "should start the thinking Time for working set items" do
                Story.promoteIntoWorkingSet(@item)
                @item.state.should be_inWorkingSet
                @item.state.itemStats.thinkingTimer.should_receive(:start)
                Story.quiz.createProblem(@item)
            end

            it "should start the thinking Time for review set items" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                @item.state.should be_inReviewSet
                @item.state.itemStats.thinkingTimer.should_receive(:start)
                Story.quiz.createProblem(@item)
            end

            it "should start the thinking Time for forgotten set items" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                Story.forget(@item)
                @item.state.should be_inForgottenSet
                @item.state.itemStats.thinkingTimer.should_receive(:start)
                Story.quiz.createProblem(@item)
            end

            # Note: Truncating times to an int because, while running the
            # tests, a very small amount of time will elapse causing the
            # tests to fail.
            it "should keep track of the time reviewing working set items" do
                Story.thinkForXSeconds(1.0)
                Story.promoteIntoWorkingSet(@item)
                Story.workingSet.stats.thinkingTime.to_i.should eql(0)
                Story.drillCorrectly(@item)
                Story.workingSet.stats.thinkingTime.to_i.should eql(1)
                Story.drillIncorrectly(@item)
                Story.workingSet.stats.thinkingTime.to_i.should eql(2)
                Story.promoteIntoReviewSet(@item)
                # It takes three correct answers to promote the item.
                # Each corect answer thinks for 1 second.
                Story.workingSet.stats.thinkingTime.to_i.should eql(5)
                # It shouldn't affect the reviewSet even though an
                # item was promoted into it.
                Story.reviewSet.stats.thinkingTime.to_i.should eql(0)
            end

            it "should keep track of the time reviewing Review set items" do
                Story.thinkForXSeconds(1.0)
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)

                # Up to now the working set collects the time
                Story.workingSet.stats.thinkingTime.to_i.should eql(3)
                Story.reviewSet.stats.thinkingTime.to_i.should eql(0)

                # Now drill in the review set
                Story.drillCorrectly(@item)
                Story.reviewSet.stats.thinkingTime.to_i.should eql(1)
                Story.drillIncorrectly(@item)
                Story.reviewSet.stats.thinkingTime.to_i.should eql(2)

                # The working set timer shouldn't change even though
                # the item is returned to the working set
                Story.workingSet.stats.thinkingTime.to_i.should eql(3)
            end

            it "should keep track of the time reviewing Forgotten set items" do
                Story.thinkForXSeconds(1.0)
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)

                # Up to now the working set collects the time
                Story.workingSet.stats.thinkingTime.to_i.should eql(3)
                Story.reviewSet.stats.thinkingTime.to_i.should eql(0)

                Story.forget(@item)
                Story.forgottenSet.stats.thinkingTime.to_i.should eql(0)

                Story.drillCorrectly(@item)
                Story.forgottenSet.stats.thinkingTime.to_i.should eql(1)
                
                # It's been moved back to the review set
                Story.forget(@item)
                Story.drillIncorrectly(@item)
                Story.forgottenSet.stats.thinkingTime.to_i.should eql(2)

                # The other sets shouldn't have changed
                Story.reviewSet.stats.thinkingTime.to_i.should eql(0)
                Story.workingSet.stats.thinkingTime.to_i.should eql(3)
            end

            it "should report pace" do
                Story.thinkForXSeconds(1.0)
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)

                # Now drill in the review set
                Story.drillCorrectly(@item)
                Story.drillIncorrectly(@item)

                # Now drill in the forgotten set
                Story.promoteIntoReviewSet(@item)
                Story.forget(@item)
                Story.drillCorrectly(@item)
                Story.forget(@item)
                Story.drillIncorrectly(@item)

                Story.workingSet.stats.thinkingTime.to_i.should eql(6)
                Story.reviewSet.stats.thinkingTime.to_i.should eql(2)
                Story.forgottenSet.stats.thinkingTime.to_i.should eql(2)

                contentStats = Story.quiz.contents.stats
                contentStats.forgottenSetReviewPace.to_i.should eql(1)
                contentStats.reviewSetReviewPace.to_i.should eql(1)
                contentStats.workingSetLearnedPace.to_i.should eql(3)
                contentStats.learnTimePercent.to_i.should eql(60)
            end

            it "should not record time if a new problem is chosen" do
                Story.thinkForXSeconds(1.0)
                Story.promoteIntoWorkingSet(@item)
                Story.quiz.createProblem(@item)
                Story.thinkAbout(@item)
                Story.thinkAbout(@item)
                Story.thinkAbout(@item)
                @item.state.itemStats.thinkingTimer.total.to_i.should eql(3)
                Story.quiz.createProblem(@item)
                @item.state.itemStats.thinkingTimer.total.to_i.should eql(0)
                Story.workingSet.stats.thinkingTime.to_i.should eql(0)
            end
        end
    end
end

