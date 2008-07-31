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
		    @mainView.update(parent.quiz)
		end
		
		def exit
		    super
		end
		
    end
end
