require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/FileProgressContext'

module JLDrill

	class LoadTanakaContext < FileProgressContext
		
		def initialize(viewBridge)
			super(viewBridge)
		end

        # Returns the filename (without the path) of the dictionary.
        def dictionaryName
            if !@parent.nil? && !@parent.quiz.nil? && 
                !@parent.quiz.options.dictionary.nil?
                return @parent.quiz.options.tanaka
            else
                return Config::TANAKA_NAME
            end
        end

        # Returns the filename of the dictionary including the path
        def getFilename
            return File.expand_path(dictionaryName, Config::TANAKA_DIR)
        end

        def getFile
            return @parent.tanaka
        end
    end		
end
