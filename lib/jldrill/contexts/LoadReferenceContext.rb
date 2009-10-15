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
            @filename = Config::DICTIONARY_PATH
            @reference = nil
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
                @reference.readLines
                @mainView.idle_add do
                    eof = @reference.parseChunk(100)
                    @mainView.update(@reference.fraction)
                    eof
                end
            end                
        end
        
		def enter(parent)
			if (!parent.nil?) && 
                    (parent.class.public_method_defined?(:reference))
                @parent = parent
    			@reference = parent.reference
    			if(!@reference.loaded?)
        			super(parent)
        			@reference.file = @filename
        			readReference
        		end
            end
		end
		
		def exit
		    super
		end
    end
end
