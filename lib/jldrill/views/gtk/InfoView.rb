require 'Context/Gtk/Widget'
require 'jldrill/views/InfoView'
require 'jldrill/views/gtk/InfoWindowWidget'
require 'gtk2'

module JLDrill::Gtk

	class InfoView < JLDrill::InfoView

        attr_reader :infoWindow
        	
		def initialize(context)
			super(context)
			@infoWindow = InfoWindow.new(self)
			@widget = Context::Gtk::Widget.new(@infoWindow)
		end
		
		def getWidget
			@widget
		end

        def destroy
            @infoWindow.destroy
        end

        def run(info)
            super(info)
            @infoWindow.execute(info)
        end
    end
end

