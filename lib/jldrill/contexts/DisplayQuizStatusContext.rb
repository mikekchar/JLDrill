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
		    quizUpdated
		    @parent.quiz.subscribe(self)
		end
		
		def exit
		    super
		end
		
		def quizUpdated
		    @mainView.update(@parent.quiz) unless @parent.nil?
		end
				
    end
end
