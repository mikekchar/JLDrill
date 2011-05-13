module Context
    # This is the Widget mixin for Context.  If you wish to be able
    # to add to, add, or remove a widget inside a View using context,
    # this mixin must be included.  This is an abstract mixin.  The
    # methods do nothing.  They should be overriden in the concrete
    # mixins.  Please see Context::Gtk::Widget for an example.
	module Widget

        # This method creates any instance variables that you might have.
        def setupWidget
        end
	
		# Use this widget as a container for the passed widget
		def addToThisWidget(widget)
		end

        # Remove the passed widget from this object.
		def removeFromThisWidget(widget)
		end

		# This method is called after the widget has been
		# successfully added to another widget
		def widgetWasAddedTo(widget)
		end
		
		# This method is called after the widget has been
		# successfully removed from another widget
		def widgetWasRemovedFrom(widget)
		end
	end
end
