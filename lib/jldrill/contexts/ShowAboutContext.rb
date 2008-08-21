require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/InfoView'
require 'jldrill/model/AboutInfo'

module JLDrill

	class ShowAboutContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.AboutView.new(self, AboutInfo.new)
        end

        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
            @mainView.run
    		self.exit
		end
    end
end
