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
    module KeepsStatistics
        # I have basically rewritten the statistics code so I've
        # moved the tests here.  
        #
        # There are many different types of statistics.  First is
        # the statistics kept about the item.
        # Each item keeps track of the number of times an items
        # was consecutively guessed correctly in the review and forgotten
        # sets.  When the item is promoted to the review set, the
        # "consecutive" counter is set to 1 and it is incremented every time
        # the item is guessed correctly, regardless of which problem
        # was shown.  If the item is demoted to the working set, the
        # "consecutive" counter is set to 0. Guessing the item correctly
        # in the working set does not increment the "consecutive" counter.
        # Items in the forgotten set still increment the "consecurtive"
        # counter whent the item is guessed correctly.
        #
        # Each item also keeps track of the amount of thinking time used
        # in either the review set or forgotten set.  The timer is started
        # from 0 when a problem is created for the item.  The timer is stopped
        # when the item is set correct, incorrect or learned.  If a new
        # item is selected from the quiz without setting the item to
        # correc, incorrect or learned, the thinking time is not changed.
        # The item only keeps track of of the thinking time for the last
        # time the item was quized in the review set or forgotten set.
        # The item does not start the timer for working set items.  If the
        # item is demoted to the working set, the previous thinking time
        # is set to zero.
        #
        # JLDrill also keeps track of general statistics for the contents.
        # Both the review and forgotten sets track the ratio of correct
        # to incorrect items (called accuracy).  You can also find the
        # reviewRate of the the next item in the forgotten and review
        # sets.  You can find the average reviewRate for all the items
        # quizzed so far in the forgotten and review sets.
        #
        # The review set keeps track of the accuracy
        # of the last 10 items you quizzed and you can retrieve the
        # percentage of items that you got right.  There is a countdown
        # that happens when the accuracy of the last 10 items in the
        # review set is at 90% or above (called the target zone).  
        # It goes from 10 to 0.  If the recent accuracy isn't in the target
        # zone, this will be 10.  Every time you guess a problem correct
        # in the review set while in the target zone, this gets decreased
        # by one. If you leave the target zone, it goes back up to 10.  
        #
        # You can find the total number of review set and forgotten set items
        # quizzed.  You can find the total number of working set items
        # that were promoted into the review set this session.
        #
        # You can find the average amount of time spent viewing review
        # set and forgotten set items.  You can find the average amount of
        # time it took for a working set item to be promoted to the
        # review set.  Finally, you can find how much time it takes
        # to learn an item compared to review an item in the review or
        # forgotten set.
        class MyStory < JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

            def setup(type)
                super(type)
                hasResetQuiz
            end
        end

        Story = MyStory.new("JLDrill Keeps Statistics Story")

        describe Story.stepName("Item Statistics") do
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

            it "should not increment consecutive for new set items" do
                @item.state.should be_inNewSet()
                @item.state.itemStats.consecutive.should eql(0)

                # We don't normally quiz newset items, but it shouldn't
                # increment consecutive anyway.
                Story.drillCorrectly(@item)
                @item.state.itemStats.consecutive.should eql(0)
            end

            it "should not increment consecutive for working set items" do
                Story.promoteIntoWorkingSet(@item)
                @item.state.should be_inWorkingSet()

                # Working set items do not increment consecutive.
                Story.drillCorrectly(@item)
                @item.state.itemStats.consecutive.should eql(0)
            end

            it "should set consecutive to 1 on promotion" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                @item.state.should be_inReviewSet()
                @item.state.itemStats.consecutive.should eql(1)
            end

            it "should increment consecutive while correct in review set" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                @item.state.should be_inReviewSet()
                @item.state.itemStats.consecutive.should eql(1)

                2.upto(9) do |i|
                    Story.drillCorrectly(@item)
                    @item.state.itemStats.consecutive.should eql(i)
                end
            end

            it "should set consecutive back to zero when demoted" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                @item.state.should be_inReviewSet()
                @item.state.itemStats.consecutive.should eql(1)

                Story.drillIncorrectly(@item)
                @item.state.should be_inWorkingSet()
                @item.state.itemStats.consecutive.should eql(0)
            end

            it "should set consecutive back to zero when reset" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                @item.state.should be_inReviewSet()
                @item.state.itemStats.consecutive.should eql(1)

                Story.quiz.resetContents()
                @item.state.should be_inNewSet()
                @item.state.itemStats.consecutive.should eql(0)
            end

            it "should increment consecutive when correct in forgotten set" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                @item.state.itemStats.consecutive.should eql(1)

                Story.forget(@item)
                @item.state.should be_inForgottenSet()
                @item.state.itemStats.consecutive.should eql(1)
              
                Story.drillCorrectly(@item)
                @item.state.should be_inReviewSet()
                @item.state.itemStats.consecutive.should eql(2)
            end

            it "should increment consecutive when correct in forgotten set" do
                Story.promoteIntoWorkingSet(@item)
                Story.promoteIntoReviewSet(@item)
                @item.state.itemStats.consecutive.should eql(1)

                Story.forget(@item)
                @item.state.should be_inForgottenSet()
                @item.state.itemStats.consecutive.should eql(1)

                Story.drillIncorrectly(@item)
                @item.state.should be_inWorkingSet()
                @item.state.itemStats.consecutive.should eql(0)
            end
        end
    end
end

