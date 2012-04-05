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

    # It seems that I never actually wrote any tests for this code.
    # Now that I'm refactoring it, I'll write the tests
    module ForgetAndRememberItems
        class MyStory< JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

            attr_reader :sampleItems
            attr_writer :sampleItems

            def setup(type)
                super(type)
                hasResetQuiz
                @sampleItems = []
            end

            # Set the current context and view to the setOptionsContext
            def setOptions
                @context = @mainContext.setOptionsContext
                @view = @context.peekAtView
            end

            def scheduleFor1Day(item)
                item.schedules.each do |schedule|
                    schedule.potential = daysInSeconds(1)
                    schedule.duration = daysInSeconds(1)
                    score = quiz.options.promoteThresh
                end
            end

        end

        Story = MyStory.new("Forget and Remember Items")

        def Story.setup(type)
            super(type)
        end
        
        describe Story.stepName("Forget items") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.sampleItems = []
                0.upto(9) do
                    item = Story.newSampleItem
                    Story.sampleItems.push(item)
                    Story.quiz.contents.addItem(item, JLDrill::Strategy.reviewSetBin)
                end
            end

            after(:each) do
                Story.shutdown
            end

            it "It should forget old items in the review set" do
                # I've set up 10 items in the review set and kept track of
                # them in the sampleItems array.  First we'll schedule each
                # for exactly 1 day.
                Story.reviewSet.length.should eql(10)
                Story.sampleItems.each do |item|
                    Story.scheduleFor1Day(item)
                end
                Story.forgottenSet.length.should eql(0)

                # The forgetting threshold goes from 0.0 to 10.0
                # 0.0 means that it is shut off completely. It should not
                # forget any items. Higher than that indicates the reviewRate
                # above which items should be moved to the forgotten set.
                
                Story.sampleItems.each_index do |i|
                    Story.sampleItems[i].schedules.each do |schedule|
                        Story.setDaysAgoReviewed(schedule, i)
                        schedule.reviewRate.should eql(i.to_f)
                    end
                end

                # At 0.0, no items are forgotten
                Story.quiz.options.forgettingThresh = 0.0
                Story.quiz.strategy.reschedule
                Story.reviewSet.length.should eql(10)
                Story.forgottenSet.length.should eql(0)

                10.downto(1) do |i|
                    Story.quiz.options.forgettingThresh = i.to_f
                    Story.quiz.strategy.reschedule
                    Story.reviewSet.length.should eql(i)
                    Story.forgottenSet.length.should eql(10 - i)
                end
            end
        end
    end
end

