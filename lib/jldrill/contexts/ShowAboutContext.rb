require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'
require 'jldrill/model/AboutInfo'

module JLDrill

	class ShowAboutContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end

        class AboutView < Context::View
    
            def initialize(context, about)
                super(context)
                @about = about
            end
	
            # Open the window and display the about information    
            def run
                # Please define in the concrete class
            end
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
