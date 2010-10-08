require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'


module JLDrill::BrowseItems

    Story = JLDrill::StoryMemento.new("Browse Items")
    def Story.setup(type)
        super(type)
        @context = @mainContext.showAllVocabularyContext
        @view = @context.peekAtView
    end
    def Story.start
        super
        @mainContext.quiz = JLDrill::SampleQuiz.new.quiz
        @mainContext.quiz.reset
    end
    def Story.quiz
        @mainContext.quiz
    end

    describe Story.stepName("Edit an item from the vocabulary list") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
        end

        after(:each) do
            Story.shutdown
        end

        it "should be display all the vocabulary" do
            Story.view.should_receive(:update)
            Story.mainContext.showAllVocabulary
        end

        it "should be able to edit one of the items" do
            Story.mainContext.showAllVocabulary
            Story.view.items.should_not be_nil
            item = Story.view.items[0]
            item.should_not be_nil
            Story.mainContext.should_receive(:editItem).with(item)
            Story.view.edit(item)
        end
    end
end
