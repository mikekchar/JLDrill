module JLDrill

	# Abstract class representing a View on a piece of UI.
	# The view is responsible for displaying information to
	# the user.  FIXME: I can't remember if it is also responsible
	# for getting the input.
	# The Context uses the view to control what the user
	# sees.
	class View
	
		attr_reader :context

		# Create the View and set it's parent context	
		def initialize(context)
			@context = context
		end
		
		# Add this View to another View.
		# This allows one UI element to contain another UI element visually.
		# Usually you will contain main View of a Context in it's parent's
		# main View.  You will also contain the subordinate Views in this View's
		# Context in the main View.
		def addView(view)
			myWidget = getWidget()
			if !myWidget.nil?
				newWidget = view.getWidget()
				myWidget.add(newWidget) unless newWidget.nil?
			end
		end
		
		# Remove a View from this View.
		def removeView(view)
			myWidget = getWidget()
			if !myWidget.nil?
				# FIXME: Remove the widget
			end
		end
		
		# Open the View.  Probably means to display it to the user.
		# It's actual use is dependent upon the concrete class.
		# Concrete classes should override this method
		def open
		end
		
		# Close the View.  Probably means to stop displaying it to the user.
		# It's actual use is dependent upon the concrete class.
		# Concrete classes should override this method
		def close
		end

		# Return the main Widget that this view contains.  This will
		# be used to add one view to another.  The concrete class should
		# determine what is the main Widget and return it here.
		# Concrete classes should override this method
		def getWidget
			return nil
		end
	end

end
