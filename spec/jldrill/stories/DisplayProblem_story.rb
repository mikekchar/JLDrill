require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/views/ProblemView'
require 'jldrill/views/gtk/ProblemView'
require 'jldrill/spec/StoryMemento'

module JLDrill::QuestionAndAnswerAreDisplayed

    Story = JLDrill::StoryMemento.new("Problems are displayed")
    def Story.setup(type)
        super(type)
        @context = @mainContext.displayProblemContext
        @view = @context.peekAtView
    end

###########################################

    describe Story.stepName("The DisplayProblemContext is entered when the MainContext is entered") do
        it "should have a DisplayProblemContext" do
            Story.setup(JLDrill)
            Story.start
            Story.context.should_not be_nil
            Story.shutdown
        end
        
        it "should enter the DisplayProblemContext when the app starts" do
            Story.setup(JLDrill)
            Story.context.should_receive(:enter).with(Story.mainContext)
            Story.start
            Story.shutdown
        end
    end

###########################################

    describe Story.stepName("The DisplayProblemContext is exited when the MainContext is exited") do
        it "should exit the DisplayProblemContext when the MainContext is exited" do
            Story.setup(JLDrill)
            Story.context.should_receive(:enter).with(Story.mainContext)
            Story.start
            Story.context.should_receive(:exit)
            Story.mainContext.exit
        end
    end
    
###########################################
    describe Story.stepName("There is a view that displays current Problem") do
        it "The display should be updated when the application starts" do
            Story.setup(JLDrill)
            Story.view.should_receive(:newProblem)
            Story.start
            Story.shutdown
        end
        
        it "should display a problem when a file is loaded" do
            Story.setup(JLDrill)
            Story.start
            Story.view.should_receive(:newProblem)
            Story.loadQuiz
            Story.shutdown
        end
        
        it "should refresh the display when the current vocab has been edited" do
            Story.setup(JLDrill)
            Story.start
            Story.view.should_receive(:newProblem).exactly(2).times
            Story.loadQuiz
            Story.mainContext.quiz.currentProblem.should_not be_nil
            Story.mainContext.quiz.currentProblem.vocab = Story.sampleQuiz.sampleVocab
            Story.shutdown
        end
    end
            
###########################################
    describe Story.stepName("Embedded returns and quotes are displayed") do
        it "has been tested in the Vocabulary spec" do
        end
    end

end
