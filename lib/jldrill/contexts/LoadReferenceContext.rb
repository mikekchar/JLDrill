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
		
		def enter(parent)
			super(parent)
			if (!parent.nil?) && (parent.class.public_method_defined?(:reference))
    			@reference = parent.reference
    			@reference.file = @filename
    			Thread.new() {
                    @reference.read { |fraction|
                        @mainView.update(fraction)
                    }
                    exit
                }
    		end
		end
		
		def exit
		    @mainView.close
		    super(exit)
		end
    end
end
