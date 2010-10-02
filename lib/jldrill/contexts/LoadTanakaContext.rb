require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/views/ReferenceProgressView'

module JLDrill

	class LoadTanakaContext < Context::Context
		
	    attr_reader :filename, :reference
        attr_writer :filename
		
		def initialize(viewBridge)
			super(viewBridge)
            @tanaka = nil
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
        def dictionaryFilename
            return File.expand_path(dictionaryName, Config::TANAKA_DIR)
        end
		
		def createViews
			@mainView = @viewBridge.ReferenceProgressView.new(self)
        end
        
        def destroyViews
            @mainView.destroy
            @mainView = nil
        end
        
        def readTanaka
            if !@tanaka.nil?
                @tanaka.file = dictionaryFilename
                @tanaka.readLines
                @mainView.idle_add do
                    eof = @tanaka.parseChunk(100)
                    @mainView.update(@tanaka.fraction)
                    eof
                end
            end
        end
        
		def enter(parent)
			if (!parent.nil?)
    			@tanaka = parent.tanaka
    			if(!@tanaka.loaded? || 
                   (@tanaka.file != dictionaryFilename))
        			super(parent)
        			readTanaka
                    # The view will exit the context when the file
                    # has finished loading.  This is because we
                    # can't exit the context until the idle process
                    # is removed, and this can only be done by the view.
        		end
            end
		end
		
		def exit
		    super
			# Show the examples as soon as this has loaded
			@parent.showExamplesContext.enter(@parent)
		end
    end
end
