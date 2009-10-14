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

        def updateProblem(problem, differs)
            # Should be overridden in the concrete class
        end
		
		def showAnswer
		    # Should be overridden in the concrete class
		end
		
		def kanjiInfo(character)
		    @context.kanjiInfo(character)
		end
		
		def kanjiLoaded?
		    @context.kanjiLoaded?
		end
		
	end
end
