require 'MainWindowView'

module JLDrill

	# This class is a factory to create the View with the correct
	# widget set.  It is abstract.  Create a concrete class for
	# the correct widget set.  Each type of View will have a method
	# here to create it.  The method will pass the Context that
	# the view will be in.
	
	class ViewFactory
	
		# Create the ViewFactory
		def initialize
			# Nothing to do
		end
		
		# Create a MainWindow View
		def createMainWindowView(context)
			MainWindowView.new(context)
		end
	end
end
