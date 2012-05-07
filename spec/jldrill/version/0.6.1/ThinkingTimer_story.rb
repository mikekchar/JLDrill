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
        # The item only keeps track of of the thinking time for the last
        # time the item was quized in the review set or forgotten set.
        # The item does not start the timer for working set items.  If the
        # item is demoted to the working set, the previous thinking time
        # is set to zero.
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
        end
    end
end

