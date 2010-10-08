require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'
require 'jldrill/views/ProblemView'

module JLDrill

	class RunCommandContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end

        class CommandView < Context::View
            def initialize(context)
                super(context)
            end

            # Reread the options and update the toolbar appearance
            def update
                # Please define in the concrete class
            end
        end
		
		def createViews
    		@mainView = @viewBridge.CommandView.new(self)
        end

        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
            if !@parent.nil?
                if !@parent.quiz.nil?
                    @parent.quiz.publisher.subscribe(self, "load")
                end
            end
		end
		
		def exit
            if !@parent.nil?
                if !@parent.quiz.nil?
                    @parent.quiz.publisher.unsubscribe(self, "load")
                end
            end
		    super
		end

        def loadUpdated(quiz)
            # This will update the toolbar based on the options.
            @mainView.update
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

		def loadTanaka
			@parent.loadTanaka
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
        
        def createNew
            @parent.createNew
        end

        def learn
            @parent.learn
        end

        def removeDups
            @parent.removeDups
        end
    end
end
