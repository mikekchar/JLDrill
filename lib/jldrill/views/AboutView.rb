require 'Context/View'

module JLDrill
	class AboutView < Context::View
	    attr_reader :quiz
	
		def initialize(context, about)
			super(context)
			@about = about
		end
		
		def run
		    # Only in the concrete class
		end
		
	end
end
