require 'Context/Context'
require 'Context/Key'
require 'Context/ViewFactory'
require 'jldrill/views/MainWindowView'

module JLDrill

	class MainContext < Context::Context
		
		def initialize(viewFactory)
			super(viewFactory)
			@mainWindowView = viewFactory.MainWindowView.new(self)
			@mainView = @mainWindowView
		end
		
		def enter(parent)
			super(parent)
			@mainWindowView.open 
		end
		
		def exit
			@parent.exit
		end
				
		def close
			exit
		end
    end
end
