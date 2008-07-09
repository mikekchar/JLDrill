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
    		end
		end
		
		def exit
		    super
		end
    end
end