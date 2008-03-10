require 'jldrill/View'

module JLDrill

	# This is the View for the main window of the application.  Pretty much
	# everything goes on here.
	class MainWindowView < View
		def initialize(context)
			super(context)
		end
		
		# Close the window
		def close
			@context.exit
		end

	end
end
