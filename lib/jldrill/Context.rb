module JLDrill

	# This class represents a User Interface "context" for the application.
	# A context is very simply the user interface that is required to
	# do something with the application.  By grouping the functionality of
	# application into contexts, it makes it much easier to find the UI
	# that you are looking for.
	# 
	# Context is an abstract class.  This class contains the functionality
	# and structure that is common to all contexts.  A context contains:
	#	parent:: The context that contains this context
	#	mainView:: The View that comprises the interface for the context
	#   viewFactory:: The ViewFactory will create a View using the correct Widget set
	class Context
		attr_reader :parent, :mainView
		attr_writer :mainView
	
		# Create a new context using the widget set used in the ViewFactory.
		# The concrete class \_must_ set the mainView in it's initialize()
		# method.
		def initialize(viewFactory)
			@parent = nil
			@mainView = nil
			@viewFactory = viewFactory
		end
	
		# Enter the context.  In other words make the functionality associated
		# with this context available to the user.  If a mainView is set,
		# it will be added to the parent's main View.
		def enter(parent)
			@parent = parent
			if !@parent.nil?
				parent.addView(@mainView) unless @mainView.nil?
			end
		end
		
		# Exit the context.  In other words, the functionality associated with
		# this context is now finished.
		def exit()
			if !@parent.nil?
				parent.removeView(@mainView) unless @mainView.nil?
			end
		end
	
		# Add the specified View to the context's main View.  What this
		# does is dependent upon the Widget set used.  But the idea is to
		# make the View visible within the set of widgets specified by
		# the main View.  Packing, layout, etc is up to the particular
		# Widget sets (and concrete View).
		def addView(view)
			@mainView.addView(view) unless @mainView.nil?
		end
		
		# Remove the specified View from the context's main View.
		def removeView(view)
			@mainView.removeView(view) unless @mainView.nil?
		end
		
	end

end
