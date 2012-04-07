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
    module LoadLegacyFiles
        # When the user loads an old file with the old bin names, "Unseen" items
        # will go into the "New" bin. Any schedules on the items will be ignored.
        # Items in the "Poor", "Fair" and "Good" bins will be put into the 
        # "Working" bin.  If there is a schedule on the item, the difficulty is
        # used to determine the potential,
        # If a schedule for a problem type is missing it will be added.  See
        # below for how to deal with the score.  Items in the "Excellent" bin
        # will be placed in the "Review" bin.  If a schedule is missing, it will
        # be added, using the same schedule data as the schedule with the lowest
        # reviewLoad (i.e., the next schedule to be drilled).  If the score
        # of any schedule is less than the promotion threshold it will be
        # set to the promotion threshold. 
        #
        # For items in the working set, we will not try to remember what
        # problem it was scheduled to review when reading in old files.
        # It will screw up the code for very little user benefit.  Instead,
        # we will identify the lowest problem type that has a score below
        # the promotion threshold.  Set the score for any higher problem
        # type to zero.  Because the reading problem schedule wasn't set,
        # this will likely clear the scores for every schedule.
        class MyStory < JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

            def setup(type)
                super(type)
            end
        end

        Story = MyStory.new("Increase Potential Interval Story")

        def Story.setup(type)
            super(type)
        end

        describe Story.stepName("Loading Legacy Files") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
            end

            after(:each) do
                Story.shutdown
            end

            it "should work around problems with legacy files" do
                # In this file the original bin names are used
                # The first item is in Unseen (New set), but it 
                # has a Meaning Problem schedule
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
                # Note: All schedules have Level which is deprecated.  It
                # should still parse with no difficulty
                fileString = %Q[
Unseen
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Potential: 432000/
Poor
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 1/Level: 0/Potential: 432000/
Fair
/Kanji: 流離う/Hint: ゾロは賞金首をかぎまわり海をさすらう男だ。/Reading: さすらう/Definitions: to wander,to roam/Markers: v5u,vi/Position: 183/Consecutive: 0/MeaningProblem/Score: 1/Level: 1/LastReviewed: 1329703440/Difficulty: 6/KanjiProblem/Score: 1/Level: 1/LastReviewed: 1329703440/Difficulty: 6/
Good
Excellent
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 4/Consecutive: 1/MeaningProblem/Score: 0/Level: 2/LastReviewed: 1329441982/Duration: 352516/Difficulty: 1/KanjiProblem/Score: 0/Level: 2/LastReviewed: 1329441982/Duration: 336171/Difficulty: 1/
Forgotten
                ]
                Story.quiz.options.promoteThresh = 2
                Story.loadStringQuiz("LegacyQuiz", fileString)

                Story.quiz.contents.newSet.size.should be(1)
                Story.quiz.contents.workingSet.size.should be(2)
                Story.quiz.contents.reviewSet.size.should be(1)
                Story.quiz.contents.forgottenSet.size.should be(0)

                newItem = Story.quiz.contents.newSet[0]
                w1Item = Story.quiz.contents.workingSet[0]
                w2Item = Story.quiz.contents.workingSet[1]
                reviewItem = Story.quiz.contents.reviewSet[0]

                # New set items should have no schedule even if they exist in the
                # file
                newItem.firstSchedule.should be_nil
                newItem.schedules.size.should eql(0)

                # Even if the file only has 2 schedules for the working set items,
                # the missing one will be created.
                w1Item.schedules.size.should eql(3)
                w2Item.schedules.size.should eql(3)

                # w1 has a potential, use it
                w1Item.schedules.each do |schedule|
                    schedule.potential.should eql(432000)
                    # There is only a meaning problem scheduled, so at level
                    # 0 its score is zeroed.
                    schedule.score.should eql(0)
                end

                # w2 has difficulty set, so the potential should be based on
                # it.
                s = w2Item.problemStatus.schedulesInTypeOrder
                s[0].score.should eql(Story.quiz.options.promoteThresh)
                s[2].score.should eql(0)
                s[1].score.should eql(1)
                w2Item.schedules.each do |schedule|
                    schedule.potential.should eql((JLDrill::Schedule.difficultyScale(6) * JLDrill::Schedule.defaultPotential).to_i)
                end

                # Only Kanji and Meaning items scheduled by default
                reviewItem.schedules.size.should eql(2)
                reviewItem.schedules.each do |schedule|
                    schedule.should be_scheduled
                    schedule.potential.should eql(schedule.duration)
                    schedule.score.should eql(Story.quiz.options.promoteThresh)
                end
            end
        end
    end
end 

