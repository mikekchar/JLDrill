require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/InfoView'

module JLDrill

	class ShowInfoContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.InfoView.new(self)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent, info)
		    super(parent)
            @mainView.run(info)
    		self.exit
		end
    end
end
