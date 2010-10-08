require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/model/Quiz/Strategy'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::ItemsHaveTimeLimits

    Story = JLDrill::StoryMemento.new("Time Limit Story")
    def Story.setup(type)
        super(type)
        @sample = JLDrill::SampleQuiz.new
        @mainContext.quiz = @sample.resetQuiz
    end

    describe Story.stepName("Review Set items have time limits") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
            quiz.options.promoteThresh = 1
            newSet.length.should_not eql(0)
            newSet[0].should_not be_nil
        end

        after(:each) do
            Story.shutdown
        end

        def quiz
            Story.mainContext.quiz
        end

        def newSet
            quiz.strategy.newSet
        end

        def currentItem
            quiz.currentProblem.item
        end

        def drillCorrectly(item)
            quiz.createProblem(item)
            quiz.correct
        end

        def promoteIntoWorkingSet(item)
            item.itemStats.should be_inNewSet
            drillCorrectly(item)
            item.itemStats.should be_inWorkingSet
        end

        def promoteIntoReviewSet(item)
            item.bin.should eql(JLDrill::Strategy.workingSetBins.begin)

            JLDrill::Strategy.workingSetBins.each do
                item.itemStats.should_not be_inNewSet
                item.itemStats.should be_inWorkingSet
                quiz.correct
            end

            item.itemStats.should be_inReviewSet
        end

        it "should start the thinkingTimer when a new problem is created" do
            item = newSet[0]
            item.itemStats.thinkingTimer.should_receive(:start)
            quiz.createProblem(item)
        end

        it "should stop the thinkingTimer when a problem is answered" do
            item = newSet[0]
            # Note: It's 3 times because Timer.start() that is called
            #       from createProblem() calls stop just in case the
            #       timer was already started.
            item.itemStats.thinkingTimer.should_receive(:stop).exactly(3).times
            quiz.createProblem(item)
            quiz.correct
            quiz.incorrect
        end

        it "should not have time limits on New Set Items" do
            item = newSet[0]
            quiz.createProblem(item)
            item.itemStats.timeLimit.should eql(0.0)
        end

        it "should not have time limits on Working Set Items" do
            item = newSet[0]
            quiz.createProblem(item)
            promoteIntoWorkingSet(item)
            item.itemStats.timeLimit.should eql(0.0)
        end

        it "should not have time limits on newly promoted Review Set Items" do
            item = newSet[0]
            quiz.createProblem(item)
            promoteIntoWorkingSet(item)
            promoteIntoReviewSet(item)
            item.itemStats.timeLimit.should eql(0.0)
        end

        it "should add a time limit after the first review" do
            item = newSet[0]
            quiz.createProblem(item)
            promoteIntoWorkingSet(item)
            promoteIntoReviewSet(item)
            drillCorrectly(item)
            item.itemStats.timeLimit.should_not eql(0.0)
        end

        it "should be able to round the time limit to 3 decimals" do
            item = newSet[0]
            item.itemStats.round(123.123456789, 3).should eql(123.123)
            item.itemStats.round(123.987654321, 3).should eql(123.988)
        end

        it "should save the time limit to 3 decimals and read it back in" do
            item = newSet[0]
            item.itemStats.timeLimit = 123.987654321
            itemString = item.to_s
            newItem = JLDrill::Item.create(itemString)
            newItem.itemStats.timeLimit.should eql(123.988)
        end
    end
end
