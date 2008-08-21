require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/ProblemView'

module JLDrill

	class RunCommandContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.CommandView.new(self)
        end

        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
		end
		
		def exit
		    super
		end

        def save
        end
        
        def saveAs
        end
        
        def export
        end
        
        def open
        end
        
        def appendFile
        end
        
        def loadReference
            @parent.loadReference
        end
        
        def quit
        end
        
        def info
        end
   
        def statistics
            @parent.showStatistics
        end
        
        def check
            @parent.showAnswer
        end
        
        def incorrect
        end
        
        def correct
        end
           
        def vocabTable
        end
        
        def options
            @parent.setOptions
        end
        
        def resetQuiz
        end
        
        def displayVocab
        end
        
        def xReference
        end
        
        def addNewVocabulary
            @parent.addNewVocabulary
        end
        
        def ack
        end
        
        def about
        end
        
        def setReviewMode(bool)
            @parent.setReviewMode(bool)
        end

        def getReviewMode
            retVal = false
            retVal = @parent.quiz.options.reviewMode unless @parent.quiz.nil?
            retVal
        end
    end
end
