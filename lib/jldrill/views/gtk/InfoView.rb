require 'jldrill/views/InfoView'
require 'jldrill/views/gtk/widgets/InfoWindow'
require 'gtk2'

module JLDrill::Gtk

	class InfoView < JLDrill::InfoView

        attr_reader :infoWindow
        	
		def initialize(context)
			super(context)
			@infoWindow = InfoWindow.new(self)
		end
		
		def getWidget
			@infoWindow
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

