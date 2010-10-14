require 'jldrill/contexts/ShowAboutContext'

module JLDrill::Test
	class AboutView < JLDrill::ShowAboutContext::AboutView
	    attr_reader :about, :hasRun
	
		def initialize(context, about)
			super(context)
			@about = about
            @hasRun = false
		end
		
		def run
            @hasRun = true
		end
		
	end
end
