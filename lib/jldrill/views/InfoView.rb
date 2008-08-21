require 'Context/View'

module JLDrill
	class InfoView < Context::View
	    attr_reader :quiz
	
		def initialize(context)
			super(context)
			@quiz = nil
		end
		
		def destroy
		    # Only in the concrete class
		end
		
		def run(info)
		    @info = info
		end
		
	end
end
