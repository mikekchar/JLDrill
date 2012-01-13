# encoding: utf-8
require 'Context/Gtk/Widget'
require 'Context/Views/Gtk/Widgets/MainWindow'
require 'Context/Views/Gtk/Widgets/VBox'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/widgets/Icon'
require 'jldrill/model/Config'
require 'gtk2'

module JLDrill::Gtk

	class MainWindowView < JLDrill::MainContext::MainWindowView
        
        attr_reader :icon, :mainWindow

		def initialize(context)
			super(context)
			@mainWindow = Context::Gtk::MainWindow.new("JLDrill", self)
            @icon = Icon.new
            @mainWindow.icon_list=([@icon.icon])

			@mainWindow.set_default_size(600, 400)
			@vbox = Context::Gtk::VBox.new
            @mainWindow.addToThisWidget(@vbox)
		end

		def getWidget
			@vbox
		end

		def destroy
		    @mainWindow.explicitDestroy
		end

		def emitDestroyEvent
			@mainWindow.signal_emit("destroy")
		end
    
        def showBusy(bool)
            @mainWindow.showBusy(bool)
        end    
	end
end
