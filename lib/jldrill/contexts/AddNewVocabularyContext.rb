require 'jldrill/contexts/ModifyVocabularyContext'

module JLDrill

	class AddNewVocabularyContext < ModifyVocabularyContext
				
		def initialize(viewBridge)
			super(viewBridge)
		end

        # This is called when the action button is pressed on the
        # view.  In this case it adds the vocabulary to the quiz.
        def doAction(vocabulary)
            retVal = false
            if vocabulary.valid?
                addVocabulary(vocabulary)
                @mainView.clearVocabulary
                retVal = true
            end
            return retVal
        end
 
		def addVocabulary(vocab)
		    if !@parent.nil? && !@parent.quiz.nil?
    		    item = @parent.quiz.appendVocab(vocab)
                @parent.displayItem(item)
    		    @parent.updateQuizStatus
    		end
		end
    end
end
