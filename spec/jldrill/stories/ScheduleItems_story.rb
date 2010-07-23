require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/model/Quiz/Strategy'
require 'jldrill/model/Quiz/Schedule'

module JLDrill::ScheduleItems
    
    Story = JLDrill::StoryMemento.new("Schedule Items Story")

    def Story.setup(type)
        super(type)
        @sample = JLDrill::SampleQuiz.new
        @mainContext.quiz = @sample.resetQuiz
    end

    describe Story.stepName("New items are scheduled from now") do
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

        def createAndPromote(item)
            item.schedule.should_not be_scheduled
            quiz.createProblem(item)
            item.schedule.should_not be_scheduled
            promoteIntoWorkingSet(item)
            item.schedule.should_not be_scheduled
            promoteIntoReviewSet(item)
            item.schedule.should be_scheduled
            item.schedule.difficulty.should eql(0)
        end

        def inDays(duration)
            return duration.to_f / (60 * 60 * 24)
        end

        def scheduleShouldBe(item, days, range=10)
            gap = inDays(item.schedule.duration)
            # There's a random +- range variation in the schedule
            gap.should be_close(days.to_f, days.to_f / range.to_f)
        end

        it "should schedule difficulty 0 items 5 days from now" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5, 10)
        end

        it "should schedule new items from now even if there are scheduled items" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5, 10)

            # Get a new item
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5, 10)
        end

	it "should set a maximum of the duration * 2 + 25%" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5, 10)
            orig = item.schedule.duration
            max = item.schedule.maxInterval
            max.should eql(item.schedule.backoff(orig.to_f * 1.25))
            # Make the item last reviewed 20 days ago
            item.schedule.lastReviewed = item.schedule.lastReviewed - 20 * 60 * 60 * 24
            item.schedule.calculateInterval.should eql(max)
            item.schedule.correct
            scheduleShouldBe(item, (max.to_f / 24 / 60 / 60).to_i, 10)
        end

        it "should schedule a minimum of the last duration" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5)
            orig = item.schedule.duration
            # Make the item last reviewed 1 day ago
            item.schedule.lastReviewed = item.schedule.lastReviewed - 60 * 60 *24

            newInterval = item.schedule.calculateInterval
            newInterval.should eql(orig)

            item.schedule.correct
            # The original schedule was 5 days +- 10%.  The new schedule
            # since it is going from now should be the same, but with
            # another +-10% variance.
            newInDays = inDays(newInterval)
            scheduleShouldBe(item, newInDays, 10)
        end

        it "should vary the backoff depending on the previous duration" do
            item = newSet[0]
            # Small numbers back off very close to 2.0
            item.schedule.backoff(100).should eql(199)
            ninetyDays = JLDrill::Duration.new
            ninetyDays.days=90
            # At 90 days the back off is around 1.5
            target = (1.5 * ninetyDays.seconds).to_i
            item.schedule.backoff(ninetyDays.seconds).should eql(target)
            # At 180 days the backoff is 1.0
            hundredEightyDays = JLDrill::Duration.new
            hundredEightyDays.days=180
            item.schedule.backoff(hundredEightyDays.seconds).should eql(hundredEightyDays.seconds)
            # At 200 days the backoff is still 1.0
            twoHundredDays = JLDrill::Duration.new
            twoHundredDays.days=200
            item.schedule.backoff(twoHundredDays.seconds).should eql(twoHundredDays.seconds)
        end 
    end
end
