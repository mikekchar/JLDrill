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
    module UseSchedulesInWorkingSetStory 
        # Originally the working set was separated into 3 bins: Poor, Fair,
        # and good.  Items in the Poor bin were given a Reading Problem.
        # Items in the Fair bin were given a Kanji Problem.  Items in the
        # Good bin were given a Meaning Problem.  Each item had a "level"
        # which indicated which one of these problems to use and a "score"
        # to determine how many times you got a problem correct at each level.
        #
        # First rename all the bins.  The original "Unseen" bin should now
        # be the "New" bin and is associated with the New Set.  "Poor", "Fair"
        # and "Good" good bins should be replaced with a single "Working" bin
        # corresponsing to the Working Set.  Rename the "Excellent" bin to
        # be the "Review" bin, corresponding to the Review Set.
        #
        # Next, remove the "level" from the Item and instead use schedules
        # to keep track of the progress in the working set.  While in the
        # working set, there should be one Schedule for each problem type.
        # In this story, all three problem types (Reading, Kanji, and Meaning)
        # will be used unless one of the problem types is invalid (for instance
        # if there is no Kanji in the item, there will be no Kanji Schedule)
        #
        # Problem types for an Item will be drilled in order of Reading, Kanji
        # and Meaning.  When a user gets a problem correct, the score for
        # the schedule is increased by one.  When selecting a problem, JLDrill
        # will select the lowest schedule for which the score is less than
        # the Promotion Threshold in the options.  If all of the schedules
        # have scores exceeding the threshold, the item is promoted into the
        # Review set.
        #
        # If the user gets a problem incorrect, the scores for all the
        # schedules are set to zero.
        #
        # When displaying the item status at the bottom of the screen, JLDrill
        # will count all the items for which the next problem will be a Reading
        # problem followed by the number that will be a Kanji Problem and then
        # the number that will be a Meaning problem.  In essence it displays
        # the count in the working set exactly the way it used to.
        #
        # When the user loads an old file with the old bin names, "Unseen" items
        # will go into the "New" bin. Any schedules on the items will be ignored.
        # Items in the "Poor", "Fair" and "Good" bins will be put into the 
        # "Working" bin.  If there is a schedule on the item, the difficulty is
        # used to determine the potential, (see IncreasePotentialInterval_story.rb)
        # If a schedule for a problem type is missing it will be added.  See
        # below for how to deal with the score.  Items in the "Excellent" bin
        # will be placed in the "Review" bin.  If a schedule is missing, it will
        # be added, using the same schedule data as the schedule with the lowest
        # reviewLoad (i.e., the next schedule to be drilled).  If the score
        # of any schedule is less than or equal to the promotion threshold in
        # the options, it will be set greater than the threshold.
        #
        # For items in the working set, we will not try to remember what
        # problem it was scheduled to review when reading in old files.
        # It will screw up the code for very little user benefit.  Instead,
        # we will identify the lowest problem type that has a score below
        # the promotion threshold.  Set the score for any higher problem
        # type to zero.  Because the reading problem schedule wasn't set,
        # this will likely clear the scores for every schedule.
        #
        # Now that I actually write this out, I realized how much work
        # it actually is.  But there's no way to refactor it without
        # doing it all.  I should have tackled this problem a lot earlier.
        class MyStory< JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

            def setup(type)
                super(type)
                hasResetQuiz
            end
        end

        Story = MyStory.new("Use Schedules In Working Set")

        def Story.setup(type)
            super(type)
        end
        
        describe Story.stepName("Changing the bin names") do
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

            it "should have the new bin names" do
                Story.newSet.name.should eql("New")
                Story.workingSet.name.should eql("Working")
                Story.reviewSet.name.should eql("Review")
                Story.forgottenSet.name.should eql("Forgotten")
            end

            it "should still accept the old names" do
                Story.quiz.contents.binNumFromName("New").should eql(JLDrill::Strategy.newSetBin)
                Story.quiz.contents.binNumFromName("Unseen").should eql(JLDrill::Strategy.newSetBin)
                Story.quiz.contents.binNumFromName("Working").should eql(JLDrill::Strategy.workingSetBin)
                Story.quiz.contents.binNumFromName("Poor").should eql(JLDrill::Strategy.workingSetBin)
                Story.quiz.contents.binNumFromName("Fair").should eql(JLDrill::Strategy.workingSetBin)
                Story.quiz.contents.binNumFromName("Good").should eql(JLDrill::Strategy.workingSetBin)
                Story.quiz.contents.binNumFromName("Review").should eql(JLDrill::Strategy.reviewSetBin)
                Story.quiz.contents.binNumFromName("Excellent").should eql(JLDrill::Strategy.reviewSetBin)
                Story.quiz.contents.binNumFromName("Forgotten").should eql(JLDrill::Strategy.forgottenSetBin)
            end
        end
        
        describe Story.stepName("Promoting new items") do
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

            it "should not have schedules on new items" do
                item = Story.newSet[0]
                item.itemStats.should be_inNewSet
                item.schedules.size.should eql(0)
                item.schedule.should be_nil
            end

            it "should be able to create a MeaningProblem for new set items" do
                # It's kind of nonsensical to create a Problem for a new set
                # item, but if we do, it shouldn't add a schedule.
                item = Story.newSet[0]
                Story.quiz.createProblem(item)
                Story.quiz.currentProblem.should be_a_kind_of(JLDrill::ReadingProblem)

                item.schedules.size.should eql(0)
                item.schedule.should be_nil
            end

            it "should create schedules for items promoted into the working set" do
                item = Story.newSet[0]
                Story.promoteIntoWorkingSet(item)
                item.itemStats.should be_inWorkingSet

                # Items in the working set have schedules for all 3 proplem types
                item.schedules.size.should eql(3)

                item.schedules.each do |schedule|
                    schedule.should_not be_scheduled
                    schedule.score.should eql(0)
                    schedule.potential.should eql(Story.daysInSeconds(5))
                end

                # We should have a ReadingProblem scheduled first
                item.schedule.should_not be_nil
                Story.quiz.createProblem(item)
                Story.quiz.currentProblem.should be_a_kind_of(JLDrill::ReadingProblem)
            end

            it "should not create Kanji problem schedules for items with no Kanji" do
                item = Story.newNoKanjiItem
                Story.quiz.contents.addItem(item, JLDrill::Strategy.newSetBin)
                Story.promoteIntoWorkingSet(item)
                
                # It doesn't have kanji so there should be only 2 schedules
                item.schedules.size.should eql(2)

                item.schedules.each do |schedule|
                    schedule.should_not be_scheduled
                    schedule.score.should eql(0)
                    schedule.potential.should eql(Story.daysInSeconds(5))
                end
            end

        end

    end
end
