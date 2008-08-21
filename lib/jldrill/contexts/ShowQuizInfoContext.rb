require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/QuizInfoView'

module JLDrill

	class ShowQuizInfoContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.QuizInfoView.new(self)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
    		@mainView.run(parent.quiz)
    		self.exit
		end
    end
end
