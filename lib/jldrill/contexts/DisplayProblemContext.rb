require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/ProblemView'

module JLDrill

	class DisplayProblemContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.ProblemView.new(self)
        end

        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
		    @parent.quiz.subscribe(self)
		    @parent.quiz.publisher.subscribe(self, "newProblem")
            newProblemUpdated(@parent.quiz)
		end
		
		def exit
		    super
		end

		def quizUpdated(quiz)
		    if quiz.currentProblem.nil?
		        if quiz.length != 0
		            quiz.drill
		        end
            else
    		    # This forces a redraw of the current problem
    		    @mainView.newProblem(quiz.currentProblem)
    		end
		end
		
		def newProblemUpdated(quiz)
            @mainView.newProblem(quiz.currentProblem)
		end

        def showAnswer
            @mainView.showAnswer
        end	
    end
end
