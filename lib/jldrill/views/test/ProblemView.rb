require 'jldrill/contexts/DisplayProblemContext'

module JLDrill::Test

    class ProblemView < JLDrill::DisplayProblemContext::ProblemView

        attr_reader :newProblem, :answerShown

        def initialize(context)
            super(context)
            @newProblem = false
            @answerShown = false
        end

        # A new problem has been added
        def newProblem(problem)
            super(problem)

            @newProblem = true
            @answerShown = false
        end	

        # The current problem has changed and needs updating
        def updateProblem(problem)
            super(problem)

            @newProblem = false
            # When the problem is updated it goes back to only showing
            # the question
            @answerShown = false
        end

        # Show the answer to the problem
        def showAnswer
            @newProblem = false
            @answerShown = true
        end
    end
end
