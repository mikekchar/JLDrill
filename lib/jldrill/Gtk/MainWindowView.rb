require 'MainWindowView'
require 'Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk

	# Represents the Gtk concrete class for the main window of
	# the application.
	class MainWindowView < JLDrill::MainWindowView
	
		# An inner class that represents the actual Gtk Widget
		# for the main window.
		class MainWindow < Gtk::Window
			def initialize(view)
				@view = view
				super('Anjin')
				connectSignals unless @view.nil?
			end
			
			# Connect the GTK and GDK signals to handlers.  In this
			# case we connect the destroy signal to closeView()
			def connectSignals
				signal_connect('destroy') do
					closeView
				end
			end

			# Closes the parent view (which will in turn close this window)			
			def closeView
				@view.close
			end
			
		end
		
		attr_reader :mainWindow
	
		def initialize(context)
			super(context)
			@mainWindow = MainWindow.new(self)
			@mainWindow.set_default_size(640, 400)
			@widget = Widget.new(@mainWindow)
		end
		
		# Open the window and show it.
		def open
			@mainWindow.show_all
		end
				
		# Return the Widget for the main view (in this case our
		# main window wrapped in a Widget object)
		def getWidget
			@widget
		end
		
		# Emit the Gtk destroy event to the main window.
		# This is really only used in testing, although it might
		# have other uses that I don't know about yet.
		def emitDestroyEvent
			@mainWindow.signal_emit("destroy")
		end
		
	end
end
