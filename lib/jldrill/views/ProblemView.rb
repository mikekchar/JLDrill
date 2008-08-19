require 'Context/View'
require 'jldrill/model/Problem'

module JLDrill
	class ProblemView < Context::View
	
		def initialize(context)
			super(context)
		end

		def run
		    super
		end	
		
		def newProblem(problem)
		    # Should be overridden in the concrete class
		end	
		
		def showAnswer
		    # Should be overridden in the concrete class
		end
		
	end
end
