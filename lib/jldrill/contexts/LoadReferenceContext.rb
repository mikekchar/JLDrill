# encoding: utf-8
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
                return Config::DICTIONARY_FILE
            end
        end

        # Returns the filename of the dictionary including the path
        def getFilename(options)
            dictFilename = File.join(Config::DICTIONARY_DIR, 
                                     dictionaryName(options))
            retVal = Config::resolveDataFile(dictFilename)

            # Debian installs the edict dictionary in /usr/share/edict
            # so it might not be in a dict directory.
            if retVal.nil?
                retVal = Config::resolveDataFile(dictionaryName(options))
            end

            return retVal
        end

        def getDeinflectionFilename
            return Config::resolveDataFile(Config::DEINFLECTION_FILE)
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
            if (options.language == "Chinese")
                parent.reference = CEDictionary.new
            else
                parent.reference = JEDictionary.new
            end
            loadReference(parent.reference, deinflect, getFilename(options))
        end

    end
end
