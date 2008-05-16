require 'Context/Context'
require 'Context/ViewFactory'
require 'jldrill/model/Config'
require 'jldrill/views/ReferenceProgressView'

module JLDrill

	class LoadReferenceContext < Context::Context
		
	    attr_reader :filename, :reference
		
		def initialize(viewFactory)
			super(viewFactory)
			@mainView = viewFactory.ReferenceProgressView.new(self)
			dictDir = File.join(Config::DATA_DIR, "dict")
            @filename = File.join(dictDir, "edict.utf")
            @reference = nil
		end
		
		def loadInBackground
   			Thread.new() do
                @reference.read do |fraction|
                    @mainView.update(fraction)
                end
                exit
            end
		end
		
		def enter(parent)
			if (!parent.nil?) && (parent.class.public_method_defined?(:reference))
    			@reference = parent.reference
    			if(!@reference.loaded?)
        			super(parent)
        			@reference.file = @filename
        			loadInBackground
        		end
            end
		end
		
		def exit
		    super
		end
    end
end
