require 'jldrill/model/Problem'
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/views/test/VocabularyView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::EditProblem

    Story = JLDrill::StoryMemento.new("Edit a Problem")
    def Story.setup(type)
        super(type)
        @context = @mainContext.editVocabularyContext
        @view = @context.peekAtView
    end
    def Story.start
        super
        @mainContext.quiz = JLDrill::SampleQuiz.new.quiz
    end
    def Story.quiz
        @mainContext.quiz
    end
    def Story.getKanjiProblem
        if quiz.currentProblem.nil?
            quiz.drill
        end
        while !quiz.currentProblem.class.eql?(JLDrill::KanjiProblem)
            quiz.correct
            quiz.drill
        end
        quiz.currentProblem
    end

    describe Story.stepName("Delete the kanji in a KanjiProblem") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
        end

        after(:each) do
            Story.shutdown
        end

        it "should be able to generate a kanji problem" do
            Story.getKanjiProblem.should be_a_kind_of(JLDrill::KanjiProblem)
        end

        it "should redo the the problem if the Kanji is removed" do
            Story.getKanjiProblem
            Story.quiz.currentProblem.should be_a_kind_of(JLDrill::KanjiProblem)
            newItem = Story.quiz.currentProblem.item
            vocab = newItem.to_o
            vocab.kanji = ""
            Story.quiz.currentProblem.vocab = vocab
            Story.quiz.currentProblem.should be_a_kind_of(JLDrill::MeaningProblem)
        end
    end

    describe Story.stepName("Edit the problem to create a duplicate.") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
        end
        
        after(:each) do
            Story.shutdown
        end

        it "should not accept a duplicate vocabulary" do
            Story.quiz.options.randomOrder = false
            Story.quiz.reset
            # Since the quiz isn't random, this will select the first item
            Story.quiz.drill
            # Now we edit it
            Story.mainContext.editVocabulary
            # We'll clone the vocabulary for the second item
            vocab = Story.quiz.contents.bins[0][1].to_o.clone
            # Now we'll try to set the vocabulary.  It should refuse
            # It shouldn't close the view
            Story.view.should_not_receive(:close)
            Story.view.vocabulary = vocab
            Story.view.action
        end

        it "should accept an altered vocabulary" do
            Story.quiz.options.randomOrder = false
            Story.quiz.reset
            # Since the quiz isn't random, this will select the first item
            Story.quiz.drill
            # Now we edit it
            Story.mainContext.editVocabulary
            # We'll clone the vocabulary for the item and modify it
            vocab = Story.quiz.contents.bins[0][0].to_o.clone
            vocab.reading = "fake"
            # Now we'll try to set the vocabulary.  It should accept it.
            # It should close the view
            Story.context.should_receive(:close)
            Story.view.vocabulary = vocab
            Story.view.action
        end

    end
end
