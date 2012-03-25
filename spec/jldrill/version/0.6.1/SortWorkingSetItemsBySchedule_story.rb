# encoding: utf-8
require 'jldrill/spec/storyFunctionality/SampleQuiz.rb'
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
        # is scheduled with a duration of 10 seconds +- 10%.  The
        # main schedule for the item is the one with the highest
        # reviewLoad (i.e., the schedule that has waited the longest as
        # a proportion of its duration).  However, any schedule with
        # a score equal to or greater than the promoteThresh will
        # not be selected.  Items in the working set are chosen based
        # on the reviewLoad of their main schedule. The item that has
        # waited the longest as a proportion of its duration is chosen.
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
        # will be rescheduled for a duration of 10 seconds +- 10%
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

            def setup(type)
                super(type)
                hasResetQuiz
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

                # Setting it to true should mean that the quiz needs
                # to be saved
                Story.quiz.options.interleavedWorkingSet = true
                Story.quiz.needsSave.should be_true

                newOptions = JLDrill::Options.new(JLDrill::Quiz.new())
                newOptions.should_not eql(Story.quiz.options)
                newOptions.interleavedWorkingSet = true
                newOptions.should eql(Story.quiz.options)

            end
        end
    end
end

