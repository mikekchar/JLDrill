require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/ProblemView'
require 'jldrill/views/CommandView'

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
            @parent.save
        end
        
        def saveAs
            @parent.saveAs
        end
        
        def open
            @parent.open
        end
        
        def appendFile
            @parent.appendFile
        end
        
        def loadReference
            @parent.loadReference
        end
        
        def quit
            @parent.quit
        end
        
        def info
            @parent.showQuizInfo
        end
   
        def statistics
            @parent.showStatistics
        end
        
        def drill
            @parent.drill
        end

        def check
            @parent.showAnswer
        end
        
        def incorrect
            @parent.incorrect
        end
        
        def correct
            @parent.correct
        end
           
        def vocabTable
            @parent.showAllVocabulary
        end
        
        def options
            @parent.setOptions
        end
        
        def resetQuiz
            @parent.reset
        end
        
        def editVocab
            @parent.editVocabulary
        end
        
        def deleteVocab
            @parent.deleteVocabulary
        end
        
        def addNewVocabulary
            @parent.addNewVocabulary
        end
        
        def ack
            @parent.showAcknowlegements
        end
        
        def about
            @parent.showAbout
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
