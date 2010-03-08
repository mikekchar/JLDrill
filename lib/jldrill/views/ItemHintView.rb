require 'Context/View'

module JLDrill
    # The ItemHintView displays information about the current item
    # that acts as hints for the user.  For instance, it might
    # indicate that the word is intrasitive, or a suru noun, etc.
	class ItemHintView < Context::View
	
		def initialize(context)
			super(context)
		end

		def newProblem(problem, differs)
		    # Should be overridden in the concrete class
		end	

        def updateProblem(problem, differs)
            # Should be overridden in the concrete class
        end
	end
end
