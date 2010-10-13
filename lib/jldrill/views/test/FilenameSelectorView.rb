require 'jldrill/contexts/GetFilenameContext'

module JLDrill::Test

	class FilenameSelectorView < JLDrill::GetFilenameContext::FilenameSelectorView
	    attr_reader  :destroyed, :run
	    attr_writer  :destroyed, :run
	
		def initialize(context)
			super(context)
			@destroyed = false
			@run = false
		end
		
		def destroy
		    @destroyed = true
		end
		
		def run(type)
		    @run = true
		end
		
	end
end
