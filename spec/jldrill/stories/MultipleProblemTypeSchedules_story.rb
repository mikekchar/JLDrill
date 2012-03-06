# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/spec/storyFunctionality/SampleQuiz'
require 'jldrill/model/problems/ProblemFactory'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::MultipleProblemTypeSchedules

    class MyStory < JLDrill::StoryMemento
        include JLDrill::StoryFunctionality::SampleQuiz

        # Set the current context and view to the setOptionsContext
        def setOptions
#            @context = @mainContext.setOptionsContext
#            @view = @context.peekAtView
        end

        def setup(type)
            super(type)
            hasDefaultQuiz
        end
    end

    Story = MyStory.new("Each Problem Type has a Schedule")

    describe Story.stepName("File stores the problem types") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
        end

        after(:each) do
            Story.shutdown
        end

        it "The problem types should have names" do
            # Doesn't matter what item we're working with
            item = Story.quiz.strategy.getItem
            # make sure it has kanji in it
            vocab = item.to_o
            vocab.kanji = "blah"
            item.setContents(vocab.to_s)
            problem = JLDrill::ProblemFactory.create(0, item, item.schedule)
            problem.name.should eql("ReadingProblem")
            problem = JLDrill::ProblemFactory.create(1, item, item.schedule)
            problem.name.should eql("KanjiProblem")
            problem = JLDrill::ProblemFactory.create(2, item, item.schedule)
            problem.name.should eql("MeaningProblem")
        end

        it "should be able to clone each of the problems" do
            # Doesn't matter what item we're working with
            item = Story.quiz.strategy.getItem
            # make sure it has kanji in it
            vocab = item.to_o
            vocab.kanji = "blah"
            item.setContents(vocab.to_s)
            problem = JLDrill::ProblemFactory.create(0, item, item.schedule)
            clone = problem.clone
            clone.should eql(problem)
            problem = JLDrill::ProblemFactory.create(1, item, item.schedule)
            clone = problem.clone
            clone.should eql(problem)
            problem = JLDrill::ProblemFactory.create(2, item, item.schedule)
            clone = problem.clone
            clone.should eql(problem)
        end

        it "should print the name for to_s" do
            # Doesn't matter what item we're working with
            item = Story.quiz.strategy.getItem
            # make sure it has kanji in it
            vocab = item.to_o
            vocab.kanji = "blah"
            item.setContents(vocab.to_s)
            problem = JLDrill::ProblemFactory.create(0, item, item.schedule)
            problem.to_s.should eql("/ReadingProblem")
            problem = JLDrill::ProblemFactory.create(1, item, item.schedule)
            problem.to_s.should eql("/KanjiProblem")
            problem = JLDrill::ProblemFactory.create(2, item, item.schedule)
            problem.to_s.should eql("/MeaningProblem")
        end
    end
end
