require 'jldrill/contexts/MainContext'
require 'jldrill/views/MainWindowView'
require 'jldrill/spec/Fakes'
require 'jldrill/model/Config'

module JLDrill
    # This is a helper class for the tests.  It makes it
    # easier to set up and tear down the test.  It also keeps track
    # of the state of the app.
    class StoryMemento
        attr_reader :storyName, :app, :mainContext, 
                    :mainView, :context, :view
    
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

        def useTestDictionary
            # Override with the small test dictionary
            rc = @mainContext.loadReferenceContext
			def rc.dictionaryName
				testsDir = File.join(JLDrill::Config::DATA_DIR, "tests")
				return File.join(testsDir, "edict.utf")
			end
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
    end
end
