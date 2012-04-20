# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/storyFunctionality/SampleQuiz.rb'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::ItemsHaveTimeLimits
    class MyStory < JLDrill::StoryMemento
        include JLDrill::StoryFunctionality::SampleQuiz

        def setup(type)
            super(type)
            hasResetQuiz
        end
    end

    Story = MyStory.new("Time Limit Story")

    describe Story.stepName("Review Set items have time limits") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
            Story.quiz.options.promoteThresh = 1
            Story.newSet.length.should_not eql(0)
            Story.newSet[0].should_not be_nil
            Story.newSet[0].state.should be_inNewSet
        end

        after(:each) do
            Story.shutdown
        end

        it "should start the thinkingTimer when a new problem is created" do
            item = Story.newSet[0]
            item.state.itemStats.thinkingTimer.should_receive(:start)
            Story.quiz.createProblem(item)
        end

        it "should stop the thinkingTimer when a problem is answered" do
            item = Story.newSet[0]
            # Note: It's 3 times because Timer.start() that is called
            #       from createProblem() calls stop just in case the
            #       timer was already started.
            item.state.itemStats.thinkingTimer.should_receive(:stop).exactly(3).times
            Story.quiz.createProblem(item)
            Story.quiz.correct
            Story.quiz.incorrect
        end

        it "should not have time limits on New Set Items" do
            item = Story.newSet[0]
            Story.quiz.createProblem(item)
            item.state.timeLimit.should eql(0.0)
        end

        it "should not have time limits on Working Set Items" do
            item = Story.newSet[0]
            Story.quiz.createProblem(item)
            Story.promoteIntoWorkingSet(item)
            item.state.should be_inWorkingSet
            item.state.timeLimit.should eql(0.0)
        end

        it "should not have time limits on newly promoted Review Set Items" do
            item = Story.newSet[0]
            Story.quiz.createProblem(item)
            Story.promoteIntoWorkingSet(item)
            item.state.should be_inWorkingSet
            Story.promoteIntoReviewSet(item)
            item.state.should be_inReviewSet
            item.state.timeLimit.should eql(0.0)
        end

        it "should add a time limit after the first review" do
            item = Story.newSet[0]
            Story.quiz.createProblem(item)
            Story.promoteIntoWorkingSet(item)
            item.state.should be_inWorkingSet
            Story.promoteIntoReviewSet(item)
            item.state.should be_inReviewSet
            Story.drillCorrectly(item)
            item.state.timeLimit.should_not eql(0.0)
        end

        it "should be able to round the time limit to 3 decimals" do
            item = Story.newSet[0]
            item.state.itemStats.round(123.123456789, 3).should eql(123.123)
            item.state.itemStats.round(123.987654321, 3).should eql(123.988)
        end

        it "should save the time limit to 3 decimals and read it back in" do
            item = Story.newSet[0]
            item.state.itemStats.timeLimit = 123.987654321
            itemString = item.to_s
            newItem = JLDrill::QuizItem.create(Story.quiz, itemString, Story.quiz.contents.newSetBin)
            newItem.state.timeLimit.should eql(123.988)
        end
    end
end
