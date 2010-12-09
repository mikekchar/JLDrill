require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadFileContext'

module JLDrill

    # Load the reference dictionary
	class LoadReferenceContext < Context::Context
		
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
            if !options.nil? && !options.dictionary.nil?
                return options.dictionary
            else
                return Config::DICTIONARY_NAME
            end
        end

        # Returns the filename of the dictionary including the path
        def getFilename(options)
            return File.expand_path(dictionaryName(options), 
                                    Config::DICTIONARY_DIR)
        end

        def getDeinflectionFilename
            return File.expand_path(Config::DEINFLECTION_NAME,
                                    Config::DEINFLECTION_DIR)
        end

        def loadDeinflection(deinflect, filename)
            @loadFileContext.onExit do
                exitLoadReferenceContext
            end
            @loadFileContext.enter(self, deinflect, filename)
        end

        def loadReference(reference, deinflect, filename)
            @loadFileContext.onExit do
               loadDeinflection(deinflect, getDeinflectionFilename) 
            end
            @loadFileContext.enter(self, reference, filename)
        end

        def exitLoadReferenceContext
            self.exit
        end

        def enter(parent, reference, deinflect, options)
            super(parent)
            loadReference(reference, deinflect, getFilename(options))
        end

    end
end
