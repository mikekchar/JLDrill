# encoding: utf-8
require 'Context/Context'
require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadFileContext'

module JLDrill

    # Load the Tanaka examples file
	class LoadTanakaContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
            @loadFileContext = LoadFileContext.new(@viewBridge)
		end

        def createViews
            @mainView =  @viewBridge.VBoxView.new(self)
        end

        def destroyViews
            @mainView = nil
        end

        def dictionaryName(options)
            if !options.nil? && !options.tanaka.nil?
                return options.tanaka
            else
                return Config::TANAKA_FILE
            end
        end

        # Returns the filename of the dictionary including the path
        def getFilename(options)
            return Config::resolveDataFile(dictionaryName(options))
        end

        def loadTanaka(tanaka, filename)
            @loadFileContext.onExit do
               exitLoadTanakaContext 
            end
            @loadFileContext.enter(self, tanaka, filename)
        end

        def exitLoadTanakaContext
            self.exit
        end

        def startLongEvent()
            @parent.startLongEvent()
        end

        def stopLongEvent()
            @parent.stopLongEvent()
        end

        def enter(parent, tanaka, options)
            super(parent)
            loadTanaka(tanaka, getFilename(options))
        end
    end
end
