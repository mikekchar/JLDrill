require 'jldrill/Gtk/MainWindowView'

module JLDrill::Gtk

	# This is the concrete ViewFactory for creating
	# a View using the Gtk Widget set.
	class ViewFactory
		def initialize
			# Nothing to do
		end
		
		# Create a MainWindow View for Gtk
		def createMainWindowView(context)
			return MainWindowView.new(context)
		end
	end
end
