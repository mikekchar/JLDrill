require 'Context/View'

module JLDrill
	class MainWindowView < Context::View
		def initialize(context)
			super(context)
		end
		
		def close
			@context.exit
		end
		
		def destroy
		    # Nothing to be done in the abstract class
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
		
		def showAnswer
		    @context.showAnswer
		end
		
	end
end
