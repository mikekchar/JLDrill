# encoding: utf-8
require 'jldrill/spec/storyFunctionality/SampleQuiz.rb'
require 'jldrill/model/quiz/Schedule'
require 'jldrill/model/quiz/Options'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::Version_0_6_1
    module NonInterleavedWorkingSet
        # While refactoring the code, I became worried that the working
        # set was not operating properly.  I wrote this story to verify
        # that it was working the way it should in the non Interleaved
        # case.
        class MyStory< JLDrill::StoryMemento
            include JLDrill::StoryFunctionality::SampleQuiz

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

        Story = MyStory.new("NonInterleavedWorkingSet")

        describe Story.stepName("Seen Items") do
            before(:each) do
                Story.setup(JLDrill::Test)
                Story.start
                Story.quiz.options.promoteThresh = 2
                Story.quiz.options.introThresh = 10
                Story.workingSet.length.should eql(1)
                @items = []
                @items[0] = Story.workingSet[1]
                1.upto(9) do |i|
                    @items[i] = Story.newSampleItem()
                    Story.quiz.contents.pushItem(@items[i], 
                                                 Story.workingSet.number)
                end
                Story.workingSet.length.should eql(10)
                Story.workingSet.should be_full
            end

            after(:each) do
                Story.shutdown
            end

            it "Set the item to seen after it is correct" do
                item = Story.quiz.getItem
                item.state.should_not be_seen
                Story.drillCorrectly(item)
                item.state.should be_seen
            end

            it "should set the item to seen after it is incorrect" do
                item = Story.quiz.getItem
                item.state.should_not be_seen
                Story.drillIncorrectly(item)
                item.state.should be_seen
            end

            it "should set the item to seen after it is learned" do
                item = Story.quiz.getItem
                item.state.should_not be_seen
                Story.learn(item)
                item.state.should be_seen
            end

            it "should show each item once before showing again" do
                seen = []
                0.upto(9) do
                    item = Story.quiz.getItem
                    Story.drillCorrectly(item)
                    i = @items.find_index(item)
                    seen.push(item.state.position) 
                end
                seen.uniq.size.should eql(10)
            end

            it "should make demoted items seen" do
                item = Story.quiz.getItem
                Story.learn(item)
                item.state.should be_inReviewSet
                item.state.should be_seen
                item.state.setAllSeen(false)
                item.state.should_not be_seen
                Story.drillIncorrectly(item)
                item.state.should be_inWorkingSet
                item.state.should be_seen
            end
        end
    end
end
