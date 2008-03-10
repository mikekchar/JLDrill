require 'jldrill/Context'
require 'jldrill/ViewFactory'

module JLDrill

	class MainContext < Context
		
		def initialize(viewFactory)
			super(viewFactory)
			@mainView = viewFactory.createMainWindowView(self)
		end
		
		def enter(parent)
			super(parent)
		end
		
		def exit
			@parent.exit unless @parent.nil?
		end				
	end
	
end

