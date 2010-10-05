require 'Context/Gtk/Widget'
require 'Context/Views/Gtk/Widgets/MainWindow'
require 'Context/Views/Gtk/Widgets/VBox'
require 'jldrill/views/MainWindowView'
require 'gtk2'

module JLDrill::Gtk

	class MainWindowView < JLDrill::MainWindowView
        
        attr_reader :icon, :mainWindow

		def initialize(context)
			super(context)
			@mainWindow = Context::Gtk::MainWindow.new("JLDrill", self)
            @icon = Gdk::Pixbuf.new(File.join(JLDrill::Config::DATA_DIR, 
                                              "icon.svg"))
            @mainWindow.icon_list=([@icon])

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
	end
end
