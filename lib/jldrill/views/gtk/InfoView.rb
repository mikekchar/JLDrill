# encoding: utf-8
require 'jldrill/contexts/ShowInfoContext'
require 'jldrill/views/gtk/widgets/InfoWindow'
require 'gtk2'

module JLDrill::Gtk

	class InfoView < JLDrill::ShowInfoContext::InfoView

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

