require 'jldrill/contexts/MainContext'
require 'jldrill/views/MainWindowView'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/spec/Fakes'

module JLDrill
    class StoryMemento
        attr_reader :storyName, :app, :mainContext, :mainView, :context, :view
    
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
    end
end
