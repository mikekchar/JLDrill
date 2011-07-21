# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class ShowInfoContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end

        class InfoView < Context::View

            def initialize(context)
                super(context)
            end

            # Destroy the info window
            def destroy
                # Please define in the concrete class
            end

            # Display the info to the user
            def run(info)
                @info = info
                # Please run super() and then define the rest
                # of the method in the concrete class
            end
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
