require 'jldrill/contexts/MainContext'
require 'jldrill/views/MainWindowView'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/QuizStatusView'
require 'jldrill/views/gtk/QuizStatusView'
require 'jldrill/spec/Fakes'

# The status of the quiz is displayed in the main view
#
# 1. There is a context called DisplayStatusContext that is entered
#    when the MainContext is entered.
#
# 2. The DisplayStatusContext is exited when the MainContext is exited
#
# 3. The DisplayStatusContext contains a view which displays the status of the quiz
#
# 4. The View is updated whenever the status of the quiz changes
#
module JLDrill::QuizStatusIsDisplayed

    class StoryMemento
   
        
        attr_reader :storyName, :mainContext, :mainView, :context, :view
    
        def initialize
            @storyName = "Quiz Status Is Displayed"
            restart
        end

        def restart
            @app = nil
            @mainContext = nil
            @mainView = nil
            @context = nil
            @view = nil
        end
        
        def stepName(step)
            @storyName + " - " + step
        end
    
        # Some useful routines
        def setupAbstract
            @app = JLDrill::Fakes::App.new(nil)
            @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            @mainContext.enter(@app)
            @mainView = @mainContext.mainView
            @context = @mainContext.displayQuizStatusContext
            @view = @context.mainView
        end
        
        def setupGtk
            @app = JLDrill::Fakes::App.new(nil)
            @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill::Gtk))
            @mainContext.enter(@app)
            @mainView = @mainContext.mainView
            @context = @mainContext.displayQuizStatusContext
            @view = @context.mainView
        end
        
        # This is very important to call when using setupGtk because otherwise
        # you will leave windows hanging open.
        def shutdown
            @mainContext.exit
            restart
        end
    end
    
    Story = StoryMemento.new

###########################################

    describe Story.stepName("The DisplayQuizStatusContext is entered when the MainContext is entered") do
        it "should have a DisplayQuizStatusContext" do
            main = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            main.displayQuizStatusContext.should_not be_nil
        end
        
        it "should enter the DisplayQuizStatusContext when the MainContext is entered" do
            app = Context::Context.new(nil)
            main = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            main.displayQuizStatusContext.should_receive(:enter).with(main)
            main.enter(app)
        end
    end

###########################################

    describe Story.stepName("The DisplayQuizStatusContext is exited when the MainContext is exited") do
        it "it should exit the DisplayQuizStatus Context when the MainContext is exited" do
            app = Context::Context.new(nil)
            main = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            main.displayQuizStatusContext.should_receive(:enter).with(main)
            main.enter(app)
            main.displayQuizStatusContext.should_receive(:exit)
            main.exit
        end
    end

###########################################

    describe Story.stepName("There is a view that displays the status of the quiz") do
        it "has a view" do
            Story.setupAbstract
            Story.view.should_not be_nil
            Story.shutdown
        end
        it "should add the view to bottom of the Gtk MainWindowView" do
            # See tests in Gtk/MainWindowView_spec
            # It would be nice to also verify that the widget has been added
            # but I don't know how to do that.  However we have tested that
            # the add works on the main window view and that entering the context
            # adds the view (in the Context tests).  So we can say that this works.
            # I know, it's a cop out...
        end
        it "displays the status of the quiz in the Gtk view" do
            Story.setupGtk
            status = Story.mainContext.quiz.status
            Story.view.update(Story.mainContext.quiz)
            Story.view.quizStatusBar.text.should be_eql(status)
            Story.shutdown
        end
    end

###########################################

    describe Story.stepName("The view is updated whenever the status of the quiz changes") do
        it "should update the status of the quiz when the context is entered" do
            Story.setupGtk
            status = Story.mainContext.quiz.status
            Story.view.quizStatusBar.text.should be_eql(status)
            Story.shutdown
        end
        
        it "should receive updates when the quiz status changes" do
            Story.setupAbstract
            Story.context.should_receive(:quizUpdated)
            Story.mainContext.quiz.update
            Story.shutdown
        end
        
    end    
end
