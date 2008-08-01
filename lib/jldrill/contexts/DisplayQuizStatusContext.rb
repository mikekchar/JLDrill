require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/QuizStatusView'

module JLDrill

	class DisplayQuizStatusContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.QuizStatusView.new(self)
        end

        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
		    quizUpdated(@parent.quiz)
		    @parent.quiz.subscribe(self)
		    @parent.quiz.publisher.subscribe(self, "newProblem")
		end
		
		def exit
		    super
		end
		
		def quizUpdated(quiz)
		    @mainView.update(quiz)
		end
		
		def newProblemUpdated(quiz)
            if @parent.reference.loaded? && !quiz.currentProblem.nil?
                exists = @parent.reference.include?(quiz.currentProblem.vocab)
		        @mainView.vocabVerified(quiz, exists)
		    end
		end
				
    end
end
