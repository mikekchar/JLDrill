require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/storyFunctionality/Gtk'
require 'jldrill/spec/storyFunctionality/SampleQuiz'
require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/views/ProblemView'

module JLDrill::QuestionAndAnswerAreDisplayed

    class MyStory < JLDrill::StoryMemento
        include JLDrill::StoryFunctionality::Gtk
        include JLDrill::StoryFunctionality::SampleQuiz
    end

    Story = MyStory.new("Problems are displayed")
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
        
        # Note: In the next two tests newProblem is received 3 times.
        # That's because it does it when the quiz is reset, when
        # the quiz is loaded and then when the first problem is
        # formed.

        it "should display a problem when a file is loaded" do
            Story.setup(JLDrill)
            Story.start
            Story.view.should_receive(:newProblem).exactly(3).times
            Story.loadQuiz
            Story.shutdown
        end
        
        it "should refresh the display when the current vocab has been edited" do
            Story.setup(JLDrill)
            Story.start
            Story.view.should_receive(:newProblem).exactly(3).times
            Story.view.should_receive(:updateProblem).exactly(1).times
            Story.loadQuiz
            Story.mainContext.quiz.currentProblem.should_not be_nil
            Story.mainContext.quiz.currentProblem.vocab = Story.sampleQuiz.sampleVocab
            Story.shutdown
        end
        
#        it "should show the answer when the user says so"
        
        it "should display each of the items in the problem" do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.view.problemDisplay.question.should_receive(:receive).exactly(3).times
            # loadQuiz will also start a drill, triggering the display
            Story.loadQuiz
            Story.view.problemDisplay.answer.should_receive(:receive)
            Story.view.showAnswer
            Story.shutdown
        end
        
        it "should have the correct text in the display" do
            Story.setup(JLDrill::Gtk)
            Story.start
            # loadQuiz will also start a drill, triggering the display
            Story.loadQuiz
            Story.view.showAnswer
            # The trailing return is for the one we don't put on the hint
            question = Story.view.problemDisplay.question.text + "\n"
            question.should be_eql(Story.mainContext.quiz.currentProblem.question)
            answer = Story.view.problemDisplay.answer.text
            answer.should be_eql(Story.mainContext.quiz.currentProblem.answer)
            Story.shutdown
        end
    end
            
###########################################
    describe Story.stepName("Embedded returns and quotes are displayed") do
        it "has been tested in the Vocabulary spec" do
        end
    end

end
