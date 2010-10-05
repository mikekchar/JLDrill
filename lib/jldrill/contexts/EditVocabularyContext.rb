require 'jldrill/contexts/ModifyVocabularyContext'

module JLDrill

	class EditVocabularyContext < ModifyVocabularyContext
				
		def initialize(viewBridge)
			super(viewBridge)
		end
	
        # When items have been updated in the quiz, If we are editing and
        # the problem changes, then the edit window should change to that
        # problem.
        def update(problem)
            super(problem)
		    @mainView.update(problem.item.to_o)
        end
		
        # Sets the vocabulary of the current problem to vocab
        # Refuses to set the vocabulary if it already exists in the
        # quiz.  Returns true if the vocabulary was set, false otherwise
        # Note, if the vocabulary is the one in the problem it will replace
        # it even if it is the same vocabulary in order to update the comment.
		def doAction(vocab)
            if @originalProblem.contains?(vocab) ||
                !@parent.quiz.exists?(vocab)
                @originalProblem.vocab = vocab
                @parent.quiz.setCurrentProblem(@originalProblem)
                return true
            else
                return false
            end
		end
    end
end
