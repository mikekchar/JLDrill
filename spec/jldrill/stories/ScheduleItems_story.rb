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

        def scheduleShouldBe(item, days)
            gap = item.schedule.duration
            gapInDays = gap.to_f / (60 * 60 * 24)
            # There's a random +- 10% variation in the schedule
            gapInDays.should be_close(days.to_f, days.to_f / 10.0)
        end

        it "should schedule difficulty 0 items 5 days from now" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5)
        end

        it "should schedule new items from now even if there are scheduled items" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5)

            # Get a new item
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5)
        end

	it "should set a maximum of the duration * 2 + 25%" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5)
            orig = item.schedule.duration
            max = item.schedule.maxInterval
            max.should eql((orig.to_f * 1.25).to_i * 2)
            # Make the item last reviewed 20 days ago
            item.schedule.lastReviewed = item.schedule.lastReviewed - 20 * 60 * 60 * 24
            item.schedule.calculateInterval.should eql(max)
            item.schedule.correct
            scheduleShouldBe(item, (max.to_f / 24 / 60 / 60).to_i)
        end

        it "should schedule a minimum of the last duration" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item, 5)
            duration = item.schedule.duration
            # Make the item last reviewed 1 day ago
            item.schedule.lastReviewed = item.schedule.lastReviewed - 60 * 60 *24
            # This is a strange way to say that the new Interval should
            # be near the old duration.
            scheduleShouldBe(item, (item.schedule.calculateInterval / 24 / 60 /60).to_i)
            # But in no way should the new interval be less than the old one
            (item.schedule.calculateInterval >= duration).should be_true
            item.schedule.correct
            # Since we are scheduling from now, the next schedule should
            # also be around 5 days.
            scheduleShouldBe(item, 5)
        end
    end
end
