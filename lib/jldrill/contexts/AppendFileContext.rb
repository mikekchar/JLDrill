require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/FileProgressContext'
require 'jldrill/contexts/GetFilenameContext'

module JLDrill

	class AppendFileContext < FileProgressContext

        attr_reader :getFilenameContext
		
		def initialize(viewBridge)
			super(viewBridge)
            @filename = nil
            @gotFilename = false
            @dict = nil
            @getFilenameContext = GetFilenameContext.new(@viewBridge)
            # Set the initial directory to the quiz Data dir
			@getFilenameContext.directory = File.join(JLDrill::Config::DATA_DIR, "quiz")
		end

        # Returns the filename of the dictionary including the path
        def getFilename
            if !@gotFilename
                @filename = getFilenameContext.enter(self, 
                                                     GetFilenameContext::OPEN)
                @gotFilename = true
            end
            return @filename
        end

        def enter(parent)
            @gotFilename = false
            super(parent)
        end

        # Returns the quiz file if the filename refers to a quiz
        # or and Edict file if it doesn't
        def getFile
            retFile = @parent.quiz
            if !getFilename.nil? &&  !JLDrill::Quiz.drillFile?(getFilename)
                @dict = Edict.new
                retFile =  @dict
            end
            return retFile
        end

        def finishParsing
            if !@dict.nil?
                @parent.quiz.loadFromDict(@dict)
                @dict = nil
            end
            
            # We need to resubscribe to the options in the new quiz
            # and realize that the options may have changed.
            @parent.quiz.options.subscribe(@parent)
            @parent.optionsUpdated(@parent.quiz.options)

            @parent.quiz.drill
            @filename = nil
            @gotFilename = false
        end
    end		
end
