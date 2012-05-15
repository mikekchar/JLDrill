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
    module CurrentRate
        # Each item has a schedule for each problem type.  The schedule
        # has a duration which indicates approximately when the item
        # should be quizzed.  There is a "reviewRate" (bad name!) which
        # indicates the ratio of time it has waited to the duration it
        # is scheduled for.  a reviewRate greater than 1 indicates that
        # the item has waited longer than expected.  A reviewRate less
        # than one indicates the the item has waited less time than expected.
        # The ContentStats keeps track of the reviewRate for the next
        # scheduled problem in the next scheduled item for both
        # the review set and the forgotten set.  It also keeps track of
        # the average reviewRate for each set.  If an item hasn't been
        # reviewed in the set, then the average review rate is 1.0.
        # After that it is the sum of reviewRates divided by the number
        # of items reviewed.
        class MyStory < JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

            def setup(type)
                super(type)
                hasResetQuiz
            end
        end

        Story = MyStory.new("Current Rate")

        describe Story.stepName("Calculates Review Rates") do
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

            it "should keep track of review rates in sets with no items" do
                Story.reviewSet.length.should eql(0)
                Story.forgottenSet.length.should eql(0)
                contentStats = Story.quiz.contents.stats
                contentStats.reviewSetRate.should eql(1.0)
                contentStats.forgottenSetRate.should eql(1.0)
                contentStats.averageReviewSetRate.should eql(1.0)
                contentStats.averageForgottenSetRate.should eql(1.0)
            end
        end
    end
end


