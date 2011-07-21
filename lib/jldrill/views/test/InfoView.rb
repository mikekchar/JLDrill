# encoding: utf-8
require 'jldrill/contexts/ShowInfoContext'

module JLDrill
	class InfoView < JLDrill::ShowInfoContext::InfoView

        attr_reader :destroyed, :hasRun
        attr_writer :destroyed, :hadRun

		def initialize(context)
			super(context)
		end
	    
		def destroy
		    @destroyed = true
		end
		
		def run(info)
            super(info)
		    @hasRun = true
		end
	end
end
