require 'jldrill/contexts/PromptContext'

module JLDrill::Test
	class PromptView < JLDrill::PromptContext::PromptView

        attr_reader :destroyed, :hasRun
        attr_writer :destroyed, :hasRun

		def initialize(context, title, message)
			super(context, title, message)
            @destroyed = false
            @hasRun = false
		end
		
		def destroy
		    @destroyed = true
		end
		
		def run
		    @hasRun = true
		end
		
	end
end
