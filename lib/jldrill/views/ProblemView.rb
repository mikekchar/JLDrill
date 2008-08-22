require 'Context/View'
require 'jldrill/model/Problem'

module JLDrill
	class ProblemView < Context::View
	
		def initialize(context)
			super(context)
		end

		def newProblem(problem, differs)
		    # Should be overridden in the concrete class
		end	
		
		def showAnswer
		    # Should be overridden in the concrete class
		end
		
		def kanjiDic
		    @context.kanjiDic
		end
		
	end
end
