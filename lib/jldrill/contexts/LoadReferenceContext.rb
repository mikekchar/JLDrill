require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/views/ReferenceProgressView'

module JLDrill

	class LoadReferenceContext < Context::Context
		
	    attr_reader :filename, :reference
        attr_writer :filename
		
		def initialize(viewBridge)
			super(viewBridge)
            @reference = nil
		end

        # Returns the filename (without the path) of the dictionary.
        def dictionaryName
            if !@parent.nil? && !@parent.quiz.nil? && 
                !@parent.quiz.options.dictionary.nil?
                return @parent.quiz.options.dictionary
            else
                return Config::DICTIONARY_NAME
            end
        end

        # Returns the filename of the dictionary including the path
        def dictionaryFilename
            return File.expand_path(dictionaryName, Config::DICTIONARY_DIR)
        end
		
		def createViews
			@mainView = @viewBridge.ReferenceProgressView.new(self)
        end
        
        def destroyViews
            @mainView.destroy
            @mainView = nil
        end
        
        def readReference
            if !@reference.nil?
                @reference.file = dictionaryFilename
                @reference.readLines
                @mainView.idle_add do
                    eof = @reference.parseChunk(100)
                    @mainView.update(@reference.fraction)
                    eof
                end
            end
        end
        
		def enter(parent)
			if (!parent.nil?)
    			@reference = parent.reference
    			if(!@reference.loaded? || 
                   (@reference.file != dictionaryFilename))
        			super(parent)
        			readReference
                    # The view will exit the context when the file
                    # has finished loading.  This is because we
                    # can't exit the context until the idle process
                    # is removed, and this can only be done by the view.
        		end
            end
		end
		
		def exit
		    super
		end
    end
end
