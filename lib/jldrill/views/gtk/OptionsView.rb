require 'jldrill/views/gtk/widgets/OptionsWindow'
require 'jldrill/views/OptionsView'
require 'gtk2'

module JLDrill::Gtk

	class OptionsView < JLDrill::OptionsView
	
        attr_reader :optionsWindow
        	
		def initialize(context)
			super(context)
			@optionsWindow = OptionsWindow.new(self)
		end
		
		def run
		    @optionsWindow.execute
		end
		
		def destroy
		    @optionsWindow.destroy
		end
		
		def update(options)
		    super(options)
		    @optionsWindow.updateFromViewData
		end
		
		def getWidget
			@optionsWindow
		end
    end
    
end

