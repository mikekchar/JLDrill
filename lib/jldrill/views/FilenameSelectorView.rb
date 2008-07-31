require 'Context/View'

module JLDrill
	class FilenameSelectorView < Context::View
	    attr_reader  :filename, :directory
	    attr_writer  :filename, :directory
	
		def initialize(context)
			super(context)
			@filename = nil
			@directory = nil
		end
		
		def destroy
		    # Only in the concrete class
		end
		
		def run
		    # Override in the concrete class
		end
		
	end
end
