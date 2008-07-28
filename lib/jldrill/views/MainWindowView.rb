require 'Context/View'

module JLDrill
	class MainWindowView < Context::View
		def initialize(context)
			super(context)
		end
		
		def close
			@context.close
		end
		
		def loadReference
		    @context.loadReference
		end
		
		def showStatistics
		    @context.showStatistics
		end
		
		def openFile
		    @context.openFile
		end
		
		def edict
		    @context.reference
		end

        def appendFile
            @context.appendFile
        end
        
        def addNewVocabulary
            @context.addNewVocabulary
        end
        
        def displayQuestion(question)
            # Should be overridden by the concrete class.
        end
		
		def setOptions
		    @context.setOptions
		end
		
		def quiz
		    @context.quiz
		end

		def quiz=(aQuiz)
		    @context.quiz = aQuiz
		end
		
		def setReviewMode(bool)
		    @context.setReviewMode(bool)
		end
		
		def updateQuiz
		    # Do work in the concrete class
		end
	end
end
