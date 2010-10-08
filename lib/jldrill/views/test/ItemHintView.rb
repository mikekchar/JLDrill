require 'jldrill/contexts/DisplayProblemContext'

module JLDrill::Test
    # The ItemHintView displays information about the current item
    # that acts as hints for the user.  For instance, it might
    # indicate that the word is intrasitive, or a suru noun, etc.
	class ItemHintView < JLDrill::DisplayProblemContext::ProblemView::ItemHintView

        attr_reader :newProblem, :problemUpdated
        attr_writer :newProblem, :problemUpdated    

		def initialize(context)
			super(context)
            @newProblem = false
		end

		def newProblem(problem)
            @newProblem = true
		end	

        def updateProblem(problem)
            @newProblem = false
            @problemUpdated = true
        end
	end
end
