require 'jldrill/contexts/DisplayProblemContext'

module JLDrill::Test
    # The ItemHintView displays information about the current item
    # that acts as hints for the user.  For instance, it might
    # indicate that the word is intrasitive, or a suru noun, etc.
	class ItemHintView < JLDrill::DisplayProblemContext::ProblemView::ItemHintView
	
		def initialize(context)
			super(context)
            @newProblem = true
		end

		def newProblem(problem)
            @newProblem = true
		end	

        def updateProblem(problem)
            # Should be overridden in the concrete class
        end

        def differs?(problem)
            @context.differs?(problem)
        end
	end
end
