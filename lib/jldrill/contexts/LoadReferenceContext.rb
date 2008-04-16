require 'Context/Context'
require 'Context/ViewFactory'
require 'jldrill/model/Config'

module JLDrill

	class LoadReferenceContext < Context::Context
		
	    attr_reader :filename, :reference
		
		def initialize(viewFactory)
			super(viewFactory)
#			@mainWindowView = viewFactory.MainWindowView.new(self)
			@mainView = nil
			dictDir = File.join(Config::DATA_DIR, "dict")
            @filename = File.join(dictDir, "edict.utf")
            @reference = nil
		end
		
		def enter(parent)
			super(parent)
			if (!parent.nil?) && (parent.class.public_method_defined?(:reference))
    			@reference = parent.reference
    			@reference.file = @filename
    			@reference.read
    		end
		end
		
		def exit
		end
				
		def close
			exit
		end
    end
end
