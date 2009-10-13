require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/model/Quiz/Strategy'

module JLDrill::ItemsHaveTimeLimits

    Story = JLDrill::StoryMemento.new("Time Limit Story")
    def Story.setup(type)
        super(type)
        @sample = JLDrill::SampleQuiz.new
        @mainContext.quiz = @sample.resetQuiz
    end

    describe Story.stepName("Review Set items have time limits") do
        before(:each) do
            Story.setup(JLDrill)
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

        it "should not have time limits on New Set Items" do
            quiz.createProblem(newSet[0])
            currentItem.itemStats.thinkingTime.should be_nil
        end

        it "should not have time limits on Working Set Items" do
            quiz.createProblem(newSet[0])
            currentItem.itemStats.should be_inNewSet
            quiz.correct
            # It should be promoted to the working set
            currentItem.itemStats.should_not be_inNewSet
            currentItem.itemStats.should be_inWorkingSet
            currentItem.itemStats.thinkingTime.should be_nil
        end

        it "should not have time limits on newly promoted Review Set Items" do
            quiz.createProblem(newSet[0])
            currentItem.itemStats.should be_inNewSet
            # Promote it into the working set
            quiz.correct
            # Promote it through the working set bins
            JLDrill::Strategy.workingSetBins.each do
                currentItem.itemStats.should_not be_inNewSet
                currentItem.itemStats.should be_inWorkingSet
                quiz.correct
            end
            currentItem.itemStats.should_not be_inNewSet
            currentItem.itemStats.should_not be_inWorkingSet
            currentItem.itemStats.should be_inReviewSet
            currentItem.itemStats.thinkingTime.should be_nil            
        end
    end
end
