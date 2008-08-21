require 'jldrill/contexts/MainContext'
require 'jldrill/views/MainWindowView'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/spec/Fakes'

# A convenience since starting up the main window is likely
# to try to open most of the views
require 'Context/require_all'
require_all 'jldrill/views/gtk/*.rb'

module JLDrill
    # This is a helper class for the tests.  It makes it
    # easier to set up and tear down the test.  It also keeps track
    # of the state of the app.
    class StoryMemento
        attr_reader :storyName, :app, :mainContext, 
                    :mainView, :context, :view, :sampleQuiz
    
        def initialize(storyName)
            @storyName = storyName
            restart
        end

        def restart
            @app = nil
            @mainContext = nil
            @mainView = nil
            @context = nil
            @view = nil
            @sampleQuiz = SampleQuiz.new
        end
        
        def stepName(step)
            @storyName + " - " + step
        end

        def setup(type)
            @app = JLDrill::Fakes::App.new(type, JLDrill::MainContext)
            @mainContext = @app.mainContext
            @mainView = @mainContext.peekAtView
        end
        
        def start
            @app.enter
        end
                
        # This is very important to call when using setupGtk because otherwise
        # you will leave windows hanging open.
        def shutdown
            @mainContext.exit
            restart
        end

        # Create a new view after the old one has been destroyed        
        def getNewView
            @view = @context.peekAtView
        end

        # Overrides the method on the object with the closure
        # that's passed in.
        def override_method(object, method, &block)
            class << object
                self
            end.send(:define_method, method, &block)
        end

        # Make the modal dialog run as if the button was pressed.	
        def enterAndPressButton(window, button, &block)
            override_method(window, :run) do
                if !block.nil?
                    block.call
                end
                button
            end
            @context.enter(@mainContext)
        end
        
        def loadQuiz
            if @mainContext.quiz.loadFromString("SampleQuiz", @sampleQuiz.resetFile)
                @mainContext.quiz.drill
            end
        end
    end
end