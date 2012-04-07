# encoding: utf-8
require 'jldrill/spec/storyFunctionality/SampleQuiz.rb'
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
        # have scores equal to the threshold, the item is promoted into the
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
                Story.quiz.contents.binNumFromName("New").should eql(Story.quiz.contents.newSetBin)
                Story.quiz.contents.binNumFromName("Unseen").should eql(Story.quiz.contents.newSetBin)
                Story.quiz.contents.binNumFromName("Working").should eql(Story.quiz.contents.workingSetBin)
                Story.quiz.contents.binNumFromName("Poor").should eql(Story.quiz.contents.workingSetBin)
                Story.quiz.contents.binNumFromName("Fair").should eql(Story.quiz.contents.workingSetBin)
                Story.quiz.contents.binNumFromName("Good").should eql(Story.quiz.contents.workingSetBin)
                Story.quiz.contents.binNumFromName("Review").should eql(Story.quiz.contents.reviewSetBin)
                Story.quiz.contents.binNumFromName("Excellent").should eql(Story.quiz.contents.reviewSetBin)
                Story.quiz.contents.binNumFromName("Forgotten").should eql(Story.quiz.contents.forgottenSetBin)
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
                item.should be_inNewSet
                item.schedules.size.should eql(0)
                item.firstSchedule.should be_nil
            end

            it "should be able to create a MeaningProblem for new set items" do
                # It's kind of nonsensical to create a Problem for a new set
                # item, but if we do, it shouldn't add a schedule.
                item = Story.newSet[0]
                Story.quiz.createProblem(item)
                Story.quiz.currentProblem.should be_a_kind_of(JLDrill::ReadingProblem)

                item.schedules.size.should eql(0)
                item.firstSchedule.should be_nil
            end

            it "should create schedules for items promoted into the working set" do
                item = Story.newSet[0]
                Story.promoteIntoWorkingSet(item)
                item.should be_inWorkingSet

                # Items in the working set have schedules for all 3 proplem types
                item.schedules.size.should eql(3)

                item.schedules.each do |schedule|
                    schedule.should_not be_scheduled
                    schedule.score.should eql(0)
                    schedule.potential.should eql(Story.daysInSeconds(5))
                end

                # We should have a ReadingProblem scheduled first
                item.firstSchedule.should_not be_nil
                Story.quiz.createProblem(item)
                Story.quiz.currentProblem.should be_a_kind_of(JLDrill::ReadingProblem)
            end

            it "should not create Kanji problem schedules for items with no Kanji" do
                item = Story.newNoKanjiItem
                Story.quiz.contents.addItem(item, Story.quiz.contents.newSetBin)
                Story.promoteIntoWorkingSet(item)
                
                # It doesn't have kanji so there should be only 2 schedules
                item.schedules.size.should eql(2)

                item.schedules.each do |schedule|
                    schedule.should_not be_scheduled
                    schedule.score.should eql(0)
                    schedule.potential.should eql(Story.daysInSeconds(5))
                end
            end

            it "present the schedules in the correct order" do
                Story.quiz.options.promoteThresh = 2
                item = Story.newSet[0]
                Story.promoteIntoWorkingSet(item)
                item.schedules.size.should eql(3)
                s = item.problemStatus.schedulesInTypeOrder
                readingSchedule = s[0]
                readingSchedule.problemType.should eql("ReadingProblem")
                kanjiSchedule = s[1]
                kanjiSchedule.problemType.should eql("KanjiProblem")
                meaningSchedule = s[2]
                meaningSchedule.problemType.should eql("MeaningProblem")

                # I should start with the reading problem
                item.firstSchedule.should be(readingSchedule)
                item.problem.should be_a_kind_of(JLDrill::ReadingProblem)
                readingSchedule.score.should eql(0)

                Story.drillCorrectly(item)
                readingSchedule.score.should eql(1)
                
                # The promotion threshold is 2 so we should still 
                # be in the same place
                item.firstSchedule.should be(readingSchedule)
                item.problem.should be_a_kind_of(JLDrill::ReadingProblem)

                Story.drillCorrectly(item)
                readingSchedule.score.should eql(2)

                # We are at the promotion threshold so we go to the
                # next schedule
                item.firstSchedule.should be(kanjiSchedule)
                item.problem.should be_a_kind_of(JLDrill::KanjiProblem)
                
                Story.drillCorrectly(item)
                Story.drillCorrectly(item)
                kanjiSchedule.score.should eql(2)
                
                # We are at the promotion threshold so we go to the
                # next schedule
                item.firstSchedule.should be(meaningSchedule)
                item.problem.should be_a_kind_of(JLDrill::MeaningProblem)
                
                Story.drillCorrectly(item)
                Story.drillCorrectly(item)

                # They should all have score equal to the promotion threshold
                readingSchedule.score.should eql(2)
                kanjiSchedule.score.should eql(2)
                meaningSchedule.score.should eql(2)

                item.should be_inReviewSet
            end

            def drillCorrectlyXTimes(item, x)
                1.upto(x) do
                    Story.drillCorrectly(item)
                end
            end

            def allScoresShouldBeZero(item)
                item.schedules.each do |schedule|
                    schedule.score.should eql(0)
                end
            end

            it "should reset the scores to zero when incorrect" do
                Story.quiz.options.promoteThresh = 2
                item = Story.newSet[0]
                Story.promoteIntoWorkingSet(item)
                
                s = item.problemStatus.schedulesInTypeOrder
                readingSchedule = s[0]
                kanjiSchedule = s[1]
                meaningSchedule = s[2]

                drillCorrectlyXTimes(item, 1)
                readingSchedule.score.should eql(1)
                Story.drillIncorrectly(item)
                allScoresShouldBeZero(item)

                drillCorrectlyXTimes(item, 3)
                readingSchedule.score.should eql(2)
                kanjiSchedule.score.should eql(1)
                Story.drillIncorrectly(item)
                allScoresShouldBeZero(item)

                drillCorrectlyXTimes(item, 5)
                readingSchedule.score.should eql(2)
                kanjiSchedule.score.should eql(2)
                meaningSchedule.score.should eql(1)
                Story.drillIncorrectly(item)
                allScoresShouldBeZero(item)

                drillCorrectlyXTimes(item, 6)
                readingSchedule.score.should eql(2)
                kanjiSchedule.score.should eql(2)
                meaningSchedule.score.should eql(2)
                item.should be_inReviewSet
                Story.drillIncorrectly(item)
                item.should be_inWorkingSet
                allScoresShouldBeZero(item)
            end
        end

        describe Story.stepName("Display Quiz Status") do
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

            # Kind of long to type and makes the tests hard to read,
            # so let's make a shorter version
            def workingStatus
                Story.quiz.contents.workingStatus
            end

            it "should display the counts in the working set according to problem type" do
                Story.quiz.options.promoteThresh = 1
                # We start with on item in the working set
                workingStatus().should eql("Working: 1, 0, 0")
                # Let's keep track of it and make 9 more
                items = [Story.workingSet[0]]
                1.upto(9) do
                    items.push(Story.newSampleItem())
                end
                1.upto(9) do |i|
                    Story.quiz.contents.addItem(items[i], 
                                                Story.quiz.contents.workingSetBin)
                    workingStatus().should eql("Working: #{i+1}, 0, 0")
                end

                # We'll promote them to the kanji problem
                0.upto(9) do |i|
                    Story.drillCorrectly(items[i])
                    workingStatus().should eql("Working: #{9-i}, #{i+1}, 0")
                end
                
                # We'll promote them to the meaning problem
                0.upto(9) do |i|
                    Story.drillCorrectly(items[i])
                    workingStatus().should eql("Working: 0, #{9-i}, #{i+1}")
                end

                # Finally promote them to review Set
                0.upto(9) do |i|
                    Story.drillCorrectly(items[i])
                    workingStatus().should eql("Working: 0, 0, #{9-i}")
                end
            end
        end

    end
end
