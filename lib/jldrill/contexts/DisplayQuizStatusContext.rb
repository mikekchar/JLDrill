require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class DisplayQuizStatusContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end

        class QuizStatusView < Context::View
            def initialize(context)
                super(context)
            end

            def update(quiz)
                # Should be overridden in the concrete class
            end	
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
		end
		
		def exit
            @parent.quiz.unsubscribe(self)
		    super
		end
		
		def quizUpdated(quiz)
		    @mainView.update(quiz)
		end
				
    end
end
