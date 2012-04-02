# encoding: utf-8
require 'jldrill/spec/storyFunctionality/SampleQuiz.rb'
require 'jldrill/spec/storyFunctionality/Gtk'
require 'jldrill/model/quiz/Strategy'
require 'jldrill/model/quiz/Schedule'
require 'jldrill/model/quiz/Options'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::Version_0_6_1
    module SortWorkingSetItemsBySchedule
        # Discussion:
        #
        # This is an implementation of a "desirable difficulty" for
        # learning items in the working set.  Currently, items are
        # learned in the order of Reading problem, Kanji Problem
        # and Meaning problem.  This allows the user to see the most
        # information first and gradually remove it.  The items
        # are also quized randomly with a roughly uniform space
        # between views. This makes the problems easy to remember.
        #
        # This story adds an option to vary the order in which
        # the problem types are introduced.  The introduction order
        # will be random.  Also, the user will not see the
        # problem types in a blocked fashion, but rather in an
        # interleaved fashion.
        #
        # Usually, if the promotion threshold is set to 2, you will
        # see the reading problem twice, the kanji problem twice
        # and then the meaning problem twice.  When the "Interleaved
        # Working Set" option is selected, the user sees each
        # problem type once (in random order) and then sees them
        # again (in a similar, though possibly different order).
        #
        # Also, the original way of presenting items in the working
        # set is to show each item once (in a random order) before
        # showing them again.  With the "Interleaved Working Set" option,
        # the items are scheduled as they are in the review set
        # (starting at 10 seconds), and the item which has waited
        # the longest in their schedule is chosen.  Furthermore, after
        # all the problems for an item have been drilled correctly
        # once, their schedules are roughly doubled.  This means they
        # will wait longer before being shown.
        #
        # The intent of this is to make it more difficult to remember
        # the item using "interleaving".  It is known as a "Desirable
        # Difficulty" because, while it is more difficult to remember,
        # once remembered, it should be harder to forget.  The scheduling
        # backoff implements a "spacing" effect.  Instead of having
        # each item presented with roughly the same interval of time,
        # the second and subsequent presentations of the problems wait
        # longer in the hopes that the user will forget the item.
        # This forgetting strengthens the memory when it is subsequently
        # learned again.
        #
        # Implementation:
        #
        # Add an option for "Interleaved" under "Working Set".  
        # When it is set, use the following scheduling strategy in 
        # the working set.
        #
        # When an item is moved to the working set, the schedules for
        # the appropriate problems are created as usual.  Each schedule
        # is scheduled with a duration of 60 seconds +- 10%. 
        # The main schedule in an item is the one with the lowest score.
        # If more than one schedule has the lowest score, the one with
        # the highest reviewLoad is chosen (the one which has waited the
        # longest as a proportion of its duration) Items in the working 
        # set are chosen based on the reviewLoad of their main schedule. 
        # The item that has waited the longest as a proportion of its 
        # duration is chosen.
        #
        # When a problem is drilled correctly, the schedule's score is
        # increased by one.  The item is rescheduled using the normal
        # backoff schedule.  However, the potential schedule is *not*
        # changed.  If the scores for all the schedules in the item
        # are equal to or greater than the promotion threshold, the item
        # is promoted to the review set.  The appropriate schedules
        # are removed/added and they are all scheduled for a duration
        # of the potential schedule +- 10%.  The potential schedule is
        # for each schedule is then set to that value.
        #
        # If the item is drilled incorrectly in the working set, *all*
        # of the schedules will have their scores set to zero and
        # will be rescheduled for a duration of 60 seconds +- 10%
        #
        # With the interleaved working set option turned on, the
        # concept of "Level" for the item is a bit different.  An item
        # is level 0 if any of the problem types have a score of 0.
        # An item is level 1 if any of the problem types have a score of 1.
        # etc.  When reporting the overall number of items in the
        # status line, JLDrill will report the number of items in each
        # level (from 0 up to promoteThresh - 1).
        class MyStory< JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz
            include JLDrill::StoryFunctionality::Gtk

            def setup(type)
                super(type)
                hasResetQuiz
            end

            # Set the current context and view to the setOptionsContext
            def setOptions
                @context = @mainContext.setOptionsContext
                @view = @context.peekAtView
            end

        end

        Story = MyStory.new("Sort Working Set Items By Schedule")

        def Story.setup(type)
            super(type)
        end
        
        describe Story.stepName("Adding Interleaved Working Set Option") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.quiz.options.promoteThresh = 2
                Story.quiz.options.introThresh = 10
                Story.newSet.length.should_not eql(0)
                Story.newSet[0].should_not be_nil
            end

            after(:each) do
                Story.shutdown
            end

            it "should have an option for interleavedWorkingSet" do
                # The quiz starts out needing to be saved because the
                # first new item has been promoted to the working set.
                # Let's pretend we've saved it.
                Story.quiz.setNeedsSave(false)
                Story.quiz.needsSave.should be_false

                # The option defaults to false
                Story.quiz.options.interleavedWorkingSet.should be_false

                newOptions = Story.quiz.options.clone()
                newOptions.should eql(Story.quiz.options)

                # Setting it to true should mean that the quiz needs
                # to be saved
                Story.quiz.options.interleavedWorkingSet = true
                Story.quiz.needsSave.should be_true

                newOptions.should_not eql(Story.quiz.options)
                newOptions.interleavedWorkingSet = true
                newOptions.should eql(Story.quiz.options)

                Story.quiz.options.to_s.should eql("Random Order\nPromotion Threshold: 2\nIntroduction Threshold: 10\nReview Meaning\nReview Kanji\nInterleaved Working Set\n")

                # Make sure we can read in the option
                no2 = JLDrill::Options.new(JLDrill::Quiz.new())
                no2.interleavedWorkingSet.should be_false
                no2.parseLine("Interleaved Working Set").should be_true
                no2.interleavedWorkingSet.should be_true
            end
        end

        describe Story.stepName("Can set the option using Options view") do
            before(:each) do
                Story.setup(JLDrill::Gtk)
                Story.start
                Story.setOptions
            end

            after(:each) do
                Story.shutdown
            end
        
            def setValueAndTest(valueString, default, target)
                modelString = "Story.mainContext.quiz.options." + valueString
                setUIString = "Story.view.optionsWindow." + 
                    valueString + " = " + target.to_s 
                eval(modelString).should eql(default)
                Story.pressOKAfterEntry(Story.view.optionsWindow) do
                    eval(setUIString)
                end
                Story.context.enter(Story.mainContext)
                eval(modelString).should eql(eval("#{target}"))
            end

            it "should be able to set the InterLeaved Working Set option" do
                setValueAndTest("interleavedWorkingSet", false, true)
            end
        end
        describe Story.stepName("Interleaved working set items") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.quiz.options.promoteThresh = 2
                Story.quiz.options.introThresh = 10
                Story.quiz.options.interleavedWorkingSet = true
                Story.newSet.length.should_not eql(0)
                Story.newSet[0].should_not be_nil
            end

            after(:each) do
                Story.shutdown
            end

            def scheduleShouldBeAroundXSeconds(schedule, seconds, variation=10)
                # There's a random +- range variation in the schedule
                # Adding +1 to the tolerance because be_within is not inclusive
                # and I want it to be
                schedule.duration.should be_within((seconds.to_f / variation.to_f).to_i + 1).of(seconds)
            end

            it "should schedule working set items" do
                item = Story.newSet[0]
                item.should_not be_nil
                item.schedules.size.should eql(0)
                Story.quiz.strategy.promote(item) 
                item.itemStats.should be_inWorkingSet
                item.schedules.size.should eql(3)
                initial = JLDrill::Schedule.initialWorkingSetInterval
                initial.should eql(60)
                item.schedules.each do |schedule|
                    schedule.should be_scheduled
                    scheduleShouldBeAroundXSeconds(schedule, initial)
                end
            end

            it "should schedule items in the working set when the options change"

            it "should unschedule items in the working set when the options change"

            # The main schedule criteria is:
            #     schedules with the lowest score are picked first
            #     if there is more than one schedule with the same score
            #         the schedule with the highest reviewLoad is picked
            it "should choose the main schedule based on reviewLoad and score"

            # The highest reviewLoad should be chosen
            it "should choose the next item to be quized based on reviewLoad"

            # It uses the normal backoff schedule.  The score for the schedule
            # is increased by one.  The potential is not changed.
            it "should reschedule the problem for items guessed correctly"

            # The schedule durations are all set to 60 seconds and the scores are
            # set to 0.  The potential schedule is reduced by 20% of its value.
            it "should reset the schedule and scores for all schedules when incorrect"

            # The status lines shows N number of "levels" 
            # (from 0 to promoteThresh - 1).  An item is "Level 0" if any of its
            # schedules has a score of 0.  An item is "Level 1" if any of its 
            # schedules has a score of 1.  Etc.  The status line shows the number of
            # items in each level in the working set.
            it "should show the status of the items in the working set"
        end
    end
end

