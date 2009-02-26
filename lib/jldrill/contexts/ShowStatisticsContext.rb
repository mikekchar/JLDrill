require 'Context/Context'
require 'Context/Bridge'

module JLDrill

	class ShowStatisticsContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.StatisticsView.new(self)
        end
        
        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def hasQuiz?(parent)
		    !parent.nil? && parent.class.public_method_defined?(:quiz) &&
		        !parent.quiz.nil?
		end
		
		def enter(parent)
		    if hasQuiz?(parent)
    		    super(parent)
    		    @mainView.update(parent.quiz)
    		    @parent.quiz.publisher.subscribe(self, "newProblem")
    		end
		end
		
		def exit
		    @parent.quiz.publisher.unsubscribe(self, "newProblem")
		    super
		end
		
		def newProblemUpdated(problem)
		    @mainView.update(@parent.quiz) unless @mainView.nil?
		end
    end
end
