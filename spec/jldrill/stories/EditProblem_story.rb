require 'jldrill/model/Problem'
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'

module JLDrill::EditProblem

    Story = JLDrill::StoryMemento.new("Edit a Problem")
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
            Story.setup(JLDrill)
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
end
