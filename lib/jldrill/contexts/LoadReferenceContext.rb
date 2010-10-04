require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/FileProgressContext'

module JLDrill

	class LoadReferenceContext < FileProgressContext
		
		def initialize(viewBridge)
			super(viewBridge)
		end

        def dictionaryName
            if !@parent.quiz.nil? && 
                !@parent.quiz.options.dictionary.nil?
                return @parent.quiz.options.dictionary
            else
                return Config::DICTIONARY_NAME
            end
        end

        # Returns the filename of the dictionary including the path
        def getFilename
            return File.expand_path(dictionaryName, Config::DICTIONARY_DIR)
        end

        def getFile
            return @parent.reference
        end
    end
end
