# encoding: utf-8
require 'Context/Views/PageView'
require 'Context/Gtk/Widget'
require 'Context/Views/Gtk/Widgets/MainWindow'
require 'gtk2'

module Context::Gtk

	class PageView < Context::PageView
	
		attr_reader :mainWindow
	
		def initialize(context, title="No Title")
			super(context)
			@mainWindow = MainWindow.new(title, self)
			@mainWindow.set_default_size(600, 400)
		end
		
		def open
            @mainWindow.open
		end
				
		def getWidget
			@mainWindow
		end
		
		def emitDestroyEvent
			@mainWindow.signal_emit("destroy")
		end
	end
end
