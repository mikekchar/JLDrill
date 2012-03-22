# encoding: utf-8
require 'jldrill/spec/storyFunctionality/SampleQuiz.rb'
require 'jldrill/model/quiz/Strategy'
require 'jldrill/model/quiz/Schedule'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::Version_0_6_1
    module IncreasePotentialIntervalStory 

        # Originally the potential schedule was set as a time between
        # 0 and 5 days using a complicated formula that decreased
        # the potential every time the items was incorrect in the working
        # set.  The potential schedule was increased if the item had
        # waited in the review set for longer than the current potential
        # schedule and was correct.  However, the maximum was 5 days.
        #
        # Simplify the decrease in schedule.  Items promoted from the new
        # set start with a potential schedule of 5 days.  Reduce the
        # potential schedule by 20% of it's current value every time it
        # is incorrect in the working set.  All schedules in for an item
        # in the working set have the same potential schedule.
        #
        # When an item is promoted to the working set, the potential schedule
        # for each schedule is set to the duration of that schedule.  If
        # an item is correct, the potential schedule *of that schedule only*
        # is set to the new duration.
        #
        # If an item is incorrect, the potential schedule for each schedule
        # is set to the potential schedule of the schedule whose problem
        # was incorrect minus 20% of that value.
        #
        # If a schedule is added, then the potential schedule is set to the
        # duration of the schedule (which should be the same as the first
        # schedule).  If a schedule is added in the working set (because
        # there is a problem type in the working set that isn't in the
        # review set), the potential schedule should be the same as the
        # other schedules.
        class MyStory < JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

            def setup(type)
                super(type)
                hasResetQuiz
            end
        end

        Story = MyStory.new("Increase Potential Interval Story")

        def Story.setup(type)
            super(type)
        end


        describe Story.stepName("Setting potential of working set items") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.quiz.options.promoteThresh = 1
                Story.newSet.length.should_not eql(0)
                Story.newSet[0].should_not be_nil
            end

            after(:each) do
                Story.shutdown
            end

            def scheduleShouldBeAroundXSeconds(schedule, seconds, variation=10)
                # There's a random +- range variation in the schedule
                schedule.duration.should be_within(seconds.to_f / variation.to_f).of(seconds)
            end

            # Drills the item incorrectly x times and returns the expected
            # potential schedule
            def drillIncorrectlyXTimes(item, x)
                potential = item.schedule.potential
                0.upto(x) do
                    Story.drillIncorrectly(item)
                    potential = potential - (0.2 * potential.to_f).to_int
                    item.schedules.each do |schedule|
                        schedule.score.should eql(0)
                        schedule.potential.should eql(potential)
                    end
                end
                return potential
            end

            it "should decrease the the potential of all schedules in the working set when incorrect" do
                item = Story.newSet[0]
                Story.promoteIntoWorkingSet(item)
                item.itemStats.should be_inWorkingSet
                potential = item.schedule.potential
                potential.should eql(Story.daysInSeconds(5))

                # Drill incorrectly 5 times and check that the
                # potential is what we expect it to be.
                drillIncorrectlyXTimes(item, 5)
            end

            it "should not change the potential when the item is correct" do
                item = Story.newSet[0]
                Story.promoteIntoWorkingSet(item)
                potential = drillIncorrectlyXTimes(item, 5)

                Story.drillCorrectly(item)
                item.schedules.each do |schedule|
                    schedule.potential.should eql(potential)
                end
            end

            it "should set the potential to the duration when the item is promoted to the review set" do
                item = Story.newSet[0]
                Story.promoteIntoWorkingSet(item)
                potential = drillIncorrectlyXTimes(item, 5)
                Story.promoteIntoReviewSet(item)
                item.itemStats.should be_inReviewSet

                # The default schedules in the review set are Kanji and Meaning only
                item.schedules.size.should eql(2)
                item.schedules.each do |schedule|
                    # Schedule duration should be +- 10% of the potential
                    scheduleShouldBeAroundXSeconds(schedule, potential, 10)
                    schedule.potential.should eql(schedule.duration)
                end
            end
        end

        describe Story.stepName("Setting potential of Review set items") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.quiz.options.promoteThresh = 1
                Story.newSet.length.should_not eql(0)
                Story.newSet[0].should_not be_nil
            end

            after(:each) do
                Story.shutdown
            end

            def scheduleShouldBeAroundXSeconds(schedule, seconds, variation=10)
                # There's a random +- range variation in the schedule
                schedule.duration.should be_within(seconds.to_f / variation.to_f).of(seconds)
            end

            it "should set the potential of items demoted to the working set to 20% less than their current potential" do
                item = Story.newSet[0]

                # Promote into the working set without any incorrect
                Story.promoteIntoWorkingSet(item)
                Story.promoteIntoReviewSet(item)

                # There should be a kanji and meaning problem schedule.
                # The duration should be 5 days +- 10%
                item.schedules.size.should eql(2)
                item.schedules.each do |schedule|
                    schedule.potential.should eql(schedule.duration)
                    scheduleShouldBeAroundXSeconds(schedule, Story.daysInSeconds(5.0), 10)
                end

                # Keep track of the two schedules for later
                s1 = item.schedules[0]
                s2 = item.schedules[1]

                # We will make it so that s1 has waited longer than s2
                Story.setDaysAgoReviewed(s1, 10.0)
                Story.setDaysAgoReviewed(s2, 5.0)

                # Since it has waited a longer percentage of it's schedule,
                # s1 will be the one chosen.
                item.schedule.should be(s1)
                # Keep track of what the new inerval is supposed to be
                interval = s1.calculateInterval

                # We'll review it as being correct.  This will create a new
                # schedule and set the potential.
                Story.quiz.strategy.correct(item)
                scheduleShouldBeAroundXSeconds(s1, interval, 10)
                s1.potential.should eql(s1.duration)
                targetPotential = s1.potential

                # s1 was just reviewed, so the next one to be reviewed will be s2
                item.schedule.should be(s2)
                # We'll make s1 wait again so that it comes back to the top.
                Story.setDaysAgoReviewed(s1, 20.0)
                item.schedule.should be(s1)

                # Make the item incorrect.  It will be moved to the working set
                Story.quiz.strategy.incorrect(item)
                item.itemStats.should be_inWorkingSet
                # We took note of the potential for the s1, so after getting it
                # wrong, the potential is decreased by 20% of its value.
                targetPotential = targetPotential - (targetPotential.to_f * 0.2).to_i

                item.schedules.size.should eql(3)
                item.schedules.each do |s|
                    s.potential.should eql(targetPotential)
                end
            end

            it "should set the potential of added schedules to be the same as the one with the lowest reviewLoad" do
                item = Story.newSet[0]

                # Promote into the working set without any incorrect
                Story.promoteIntoWorkingSet(item)
                Story.promoteIntoReviewSet(item)

                # There should be a kanji and meaning problem schedule.
                # The duration should be 5 days +- 10%
                item.schedules.size.should eql(2)
                item.schedules.each do |schedule|
                    schedule.potential.should eql(schedule.duration)
                    scheduleShouldBeAroundXSeconds(schedule, Story.daysInSeconds(5.0), 10)
                end

                # Keep track of the two schedules for later
                s1 = item.schedules[0]
                s2 = item.schedules[1]

                # We will make it so that s1 has waited longer than s2
                Story.setDaysAgoReviewed(s1, 10.0)
                Story.setDaysAgoReviewed(s2, 5.0)

                # Since it has waited a longer percentage of it's schedule,
                # s1 will be the one chosen.
                item.schedule.should be(s1)

                # Setting the options to include reading problems should
                # automatically add a schedule for the reading problem.
                Story.quiz.options.reviewReading = true
                item.schedules.size.should eql(3)

                # This new schedule should be the same as s1 (which has waited
                # the longest).  If we sort by reviewLoad, the first two
                # items should have the same potential as s1 (one of them
                # is s1, the other is the readingProblem schedule).  The last
                # one will be s2
                sortedSchedules = item.schedules.sort do |x,y|
                    x.reviewLoad <=> y.reviewLoad
                end
                sortedSchedules[0].potential.should eql(s1.potential)
                sortedSchedules[1].potential.should eql(s1.potential)
                sortedSchedules[2].potential.should eql(s2.potential)

            end
        end

        describe Story.stepName("Loading Legacy Files") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.quiz.options.promoteThresh = 1
                Story.newSet.length.should_not eql(0)
                Story.newSet[0].should_not be_nil
            end

            after(:each) do
                Story.shutdown
            end

            it "should work around problems with legacy files" do
                # In this file the original bin names are used
                # The first item is in Unseen (New set), but it has a Meaning Problem
                # schedule
                # The second item is in Poor (first working set), 
                # but it only has a Meaning Problem
                # The third item is in Fair (second working set).
                # It has Meaning and Kanji Problems with no potential set,
                # but a difficulty.
                # The fourth item is in Good (third working set).  
                # It has Kanji and Meaning problems and they are scheduled
                # The fifth item is in Excellent (review set).  
                # It has Kanji and Meaning problems with difficulty set, 
                # and scores set to 0.
                fileString = %Q[
Unseen
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Potential: 432000/
Poor
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Potential: 432000/
Fair
/Kanji: 流離う/Hint: ゾロは賞金首をかぎまわり海をさすらう男だ。/Reading: さすらう/Definitions: to wander,to roam/Markers: v5u,vi/Position: 183/Consecutive: 0/MeaningProblem/Score: 1/Level: 0/LastReviewed: 1329703440/Difficulty: 6/KanjiProblem/Score: 1/Level: 0/LastReviewed: 1329703440/Difficulty: 6/
Good
Excellent
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 4/Consecutive: 1/MeaningProblem/Score: 0/Level: 2/LastReviewed: 1329441982/Duration: 352516/Difficulty: 1/KanjiProblem/Score: 0/Level: 2/LastReviewed: 1329441982/Duration: 336171/Difficulty: 1/
Forgotten
                ]
                quiz = JLDrill::Quiz.new
                quiz.loadFromString("LegacyQuiz", Story.sampleQuiz.header + 
                                    Story.sampleQuiz.info +
                                    fileString)

                quiz.contents.bins[JLDrill::Strategy.newSetBin].size.should be(1)
                quiz.contents.bins[JLDrill::Strategy.workingSetBin].size.should be(2)
                quiz.contents.bins[JLDrill::Strategy.reviewSetBin].size.should be(1)
                quiz.contents.bins[JLDrill::Strategy.forgottenSetBin].size.should be(0)

                newItem = quiz.contents.bins[JLDrill::Strategy.newSetBin][0]
                w1Item = quiz.contents.bins[JLDrill::Strategy.workingSetBin][0]
                w2Item = quiz.contents.bins[JLDrill::Strategy.workingSetBin][1]
                reviewItem = quiz.contents.bins[JLDrill::Strategy.reviewSetBin][0]

                # New set items should have no schedule even if they exist in the
                # file
                newItem.schedule.should be_nil
                newItem.schedules.size.should eql(0)

                # Even if the file only has 2 schedules for the working set items,
                # the missing one will be created.
                w1Item.schedules.size.should eql(3)
                w2Item.schedules.size.should eql(3)

                # w1 has a potential, use it
                w1Item.schedules.each do |schedule|
                    schedule.potential.should eql(432000)
                end

                # w2 has difficulty set, so the potential should be based on
                # it.
                w2Item.schedules.each do |schedule|
                    schedule.potential.should eql((JLDrill::Schedule.difficultyScale(6) * JLDrill::Schedule.defaultPotential).to_i)
                end

                # Only Kanji and Meaning items scheduled by default
                reviewItem.schedules.size.should eql(2)
                reviewItem.schedules.each do |schedule|
                    schedule.should be_scheduled
                    schedule.potential.should eql(schedule.duration)
                    schedule.score.should eql(quiz.options.promoteThresh)
                end
            end
        end
    end
end
