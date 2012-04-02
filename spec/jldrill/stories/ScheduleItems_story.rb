# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/model/quiz/Strategy'
require 'jldrill/model/quiz/Schedule'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/VBoxView'
require 'jldrill/views/test/FileProgress'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::ScheduleItems
    
    Story = JLDrill::StoryMemento.new("Schedule Items Story")

    def Story.setup(type)
        super(type)
        @sample = JLDrill::SampleQuiz.new
        @mainContext.quiz = @sample.resetQuiz
    end

    describe Story.stepName("New items are scheduled from now") do
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

        def reviewSet
            quiz.strategy.reviewSet
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
            quiz.strategy.promote(item)
            item.itemStats.should be_inWorkingSet
        end

        def promoteIntoReviewSet(item)
            item.bin.should eql(JLDrill::Strategy.workingSetBin)

            0.upto(2) do
                item.itemStats.should_not be_inNewSet
                item.itemStats.should be_inWorkingSet
                quiz.correct
            end

            item.itemStats.should be_inReviewSet
        end

        def createAndPromote(item)
            # Items in the new set do not have schedules
            item.schedule.should be_nil

            # Creating a Problem in the new set it kind of strange,
            # but if we do it, it should work and it shouldn't
            # screw up the schedules
            quiz.createProblem(item)
            item.schedule.should be_nil

            # Promoting in the working set creates schedules
            # for the problems, but it doesn't actually schedule them.
            # The promotion criteria for working set items is the score.
            promoteIntoWorkingSet(item)
            # Items in the working set have schedules for all 3 proplem types
            item.schedules.size.should eql(3)
            item.schedules.each do |schedule|
                schedule.should_not be_scheduled
                schedule.score.should eql(0)
            end
            # The schedule method should pick one of these
            item.schedule.should_not be_nil

            # Once it is promoted into the review set, the schedules
            # should actually be scheduled.  Since we didn't get anything
            # wrong, the duration should be 5 days +- 10%.  The
            # potential should be set to the duration.
            promoteIntoReviewSet(item)
            item.schedules.each do |schedule|
                schedule.should be_scheduled
                scheduleShouldBe(schedule, 5, 10)
                schedule.potential.should eql(schedule.duration)
            end
            item.schedule.should_not be_nil
        end

        def inDays(duration)
            return duration.to_f / (60 * 60 * 24)
        end

        def inSeconds(days)
            return (days.to_f * (60 * 60 * 24)).round
        end

        def setDaysAgoReviewed(schedule, days)
            schedule.lastReviewed = Time::now() - inSeconds(days)
        end

        def scheduleShouldBe(schedule, days, range=10)
            gap = inDays(schedule.duration)
            # There's a random +- range variation in the schedule
            # Adding 0.0001 to the tolerance because be_within is not
            # inclusive and I want it to be.
            gap.should be_within((days.to_f / range.to_f) + 0.0001).of(days)
        end

        it "should schedule new items 5 days from now" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item.schedule, 5.0, 10)
        end

        it "should schedule new items from now even if there are scheduled items" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item.schedule, 5.0, 10)

            # Get a new item
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item.schedule, 5.0, 10)
        end

        it "should set a maximum of the duration * 2 + 25%" do
            item = newSet[0]
            createAndPromote(item)
            scheduleShouldBe(item.schedule, 5.0, 10)
            orig = item.schedule.duration
            max = item.schedule.maxInterval
            max.should eql(JLDrill::Schedule.backoff(orig.to_f * 1.25))

            # Make the item last reviewed 20 days ago
            schedule = item.schedule
            schedule.lastReviewed = setDaysAgoReviewed(schedule, 20.0)
            schedule.calculateInterval.should eql(max)
            schedule.correct
            scheduleShouldBe(schedule, (max.to_f / 24 / 60 / 60), 10)
        end

        it "should schedule a minimum of the last duration" do
            item = newSet[0]
            createAndPromote(item)
            schedule = item.schedule
            scheduleShouldBe(schedule, 5.0, 10)
            orig = schedule.duration
            # Make the item last reviewed 1 day ago
            schedule.lastReviewed = setDaysAgoReviewed(schedule, 1.0)
            schedule.elapsedTime.should eql(inSeconds(1.0))

            newInterval = schedule.calculateInterval
            newInterval.should eql(orig)

            schedule.correct
            # The original schedule was 5 days +- 10%.  The new schedule
            # since it is going from now should be the same, but with
            # another +-10% variance.
            newInDays = inDays(newInterval)
            scheduleShouldBe(schedule, newInDays, 10)
        end

        it "should vary the backoff depending on the previous duration" do
            item = newSet[0]
            # Small numbers back off very close to 2.0
            JLDrill::Schedule.backoff(100).should eql(199)
            ninetyDays = JLDrill::Duration.new
            ninetyDays.days=90
            # At 90 days the back off is around 1.5
            target = (1.5 * ninetyDays.seconds).to_i
            JLDrill::Schedule.backoff(ninetyDays.seconds).should eql(target)
            # At 180 days the backoff is 1.0
            hundredEightyDays = JLDrill::Duration.new
            hundredEightyDays.days=180
            JLDrill::Schedule.backoff(hundredEightyDays.seconds).should eql(hundredEightyDays.seconds)
            # At 200 days the backoff is still 1.0
            twoHundredDays = JLDrill::Duration.new
            twoHundredDays.days=200
            JLDrill::Schedule.backoff(twoHundredDays.seconds).should eql(twoHundredDays.seconds)
        end 

        it "should set the potential schedule of failed items to the time elapsed" do
            quiz.options.reviewKanji = false
            item = newSet[0]

            createAndPromote(item)
            item.schedules.size.should eql(1)

            schedule = item.schedule
            scheduleShouldBe(schedule, 5.0, 10)
            orig = schedule.potential

            # Make the item last reviewed 10 day ago
            schedule.lastReviewed = setDaysAgoReviewed(schedule, 10.0)
            schedule.elapsedTime.should eql(inSeconds(10.0))

            quiz.strategy.correct(item)
            second = item.schedule.potential

            schedule.lastReviewed = setDaysAgoReviewed(schedule, 10.0)
            quiz.strategy.correct(item)
            third = item.schedule.potential

            # Make the item incorrect.  It will be moved to the working set
            quiz.strategy.incorrect(item)

            item.schedules.size.should eql(3)
            item.schedules.each do |s|
                s.potential.should eql(third - (third *0.2).to_i)
            end
        end

        it "should be able to sort the review set items according to schedule" do
            item = newSet[0]
            createAndPromote(item)
            schedule = item.schedule
            scheduleShouldBe(schedule, 5.0, 10)
            problemStatus = item.status.select("ProblemStatus")
            # By default a meaning and kanji problem schedule 
            # are created if the item has kanji (which is should)
            # Note: A reading problem schedule is *not* present by default!
            problemStatus.schedules.size.should eql(2)

            # Everything has been promoted so the current level
            # should be 3 and there should be no associated schedule for it
            problemStatus.currentLevel.should eql(3)
            problemStatus.findScheduleForLevel(3).should eql(nil)

            # Both of the schedules should be between 4.5 and 5.5 days
            # Adding 0.0001 to the tolerance because be_within is not inclusive
            # and I want it to be
            inDays(problemStatus.schedules[0].duration).should be_within(0.5001).of(5.0)
            inDays(problemStatus.schedules[1].duration).should be_within(0.5001).of(5.0)

            # Pretend we reviewed this a day ago so that the schedules will
            # sort properly
            setDaysAgoReviewed(problemStatus.schedules[0], 1.0)
            setDaysAgoReviewed(problemStatus.schedules[1], 1.0)

            schedule1 = problemStatus.firstSchedule
            index1 = problemStatus.schedules.find_index(schedule1)

            # Make this one 6.0 days in duration so that the second schedule
            # will be shorter than this one.
            schedule1.duration = inSeconds(6.0)

            schedule2 = problemStatus.firstSchedule
            index2 = problemStatus.schedules.find_index(schedule2)

            # These should be different problem types
            index2.should_not eql(index1)

            item2 = newSet[0]
            createAndPromote(item2)
            scheduleShouldBe(item2.schedule, 5.0, 10)

            # New items are always placed at the back of the reviewSet
            reviewSet[0].should be(item)
            reviewSet[1].should be(item2)

            # Pretend we reviewed this an hour ago so that the schedules will
            # sort properly (You have to do it twice to get both
            # scheduled problem types)
            setDaysAgoReviewed(item2.schedule, 1.0/24.0)
            setDaysAgoReviewed(item2.schedule, 1.0/24.0)

            # If we reschedule
            quiz.strategy.quiz.should be(quiz)
            quiz.options.should be quiz.strategy.options
            quiz.options.promoteThresh.should eql(quiz.strategy.options.promoteThresh)
            quiz.reschedule

            # Both problem types in item were reviewed a day ago, but
            # item2 has waited 0 time, so item will be prioritized over
            # item2.
            reviewSet[0].should be(item)
            reviewSet[1].should be(item2)

            # Now we pretend that one of the problem types in item 2
            # was reviewed 50 days ago and reschedule
            setDaysAgoReviewed(item2.schedule, 50.0)
            quiz.reschedule

            # Because one of the problem types has waited a
            # very long time, item2 is sorted to the front.
            reviewSet[0].should be(item2)
            reviewSet[1].should be(item)

        end
   end
end
