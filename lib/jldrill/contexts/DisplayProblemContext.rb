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
		    @parent.quiz.publisher.subscribe(self, "newProblem")
		    @parent.quiz.publisher.subscribe(self, "problemModified")
            newProblemUpdated(@parent.quiz)
		end
		
		def exit
		    super
		end

        def differs?(problem)
            exists = true
            if @parent.reference.loaded? && !problem.nil?
                exists = @parent.reference.include?(problem.vocab)
		    end
		    return !exists
        end

		def newProblemUpdated(quiz)
            @mainView.newProblem(quiz.currentProblem, differs?(quiz.currentProblem))
		end

		def problemModifiedUpdated(quiz)
            @mainView.newProblem(quiz.currentProblem, differs?(quiz.currentProblem))
		end

        def showAnswer
            @mainView.showAnswer
        end	
    end
end
