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
		
		def enter(parent)
		    super(parent)
		end
		
		def exit
		    super
		end
    end
end
