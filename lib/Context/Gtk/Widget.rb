require 'Context/Widget'
require 'Context/Log'
require 'gtk2'

module Context::Gtk
    include Context::Widget

    # This is a set of routines for translating the requests
    # from Context to the specific widgit set.
    #
    # Note: If you wish your widget to be able to add and removed
    #       other widgets (i.e. if it can act as a container), then
    #       please define the following two methods on your object.
    #
    #       gtkAddWidget(widget) -- simply adds the passed widget to
    #                               the correct Gtk container.  Normally
    #                               this can be implemented using add().
    #                               However, for some things like tables
    #                               you will have to use other methods.
    #       gtkRemoveWidget(widget) -- removes the passed widget from
    #                                  the correct Gtk container.  Again
    #                                  you will normally implement this
    #                                  with remove().
    #
    #       The following also need to be defined if your widget is
    #       not derived from a Gtk:Widget.
    #
    #       show_all() -- Displays the widgets.

	module Widget
	    attr_reader :gtkWidgetMainWindow
	    attr_writer :gtkWidgetMainWindow
	    
	    def setupWidget
	        @gtkWidgetMainWindow = nil
	        # Packing hints for the container
	        @gtkWidgetExpandHeight = false
	        @gtkWidgetExpandWidth = false
            @gtkWidgetAddedToCallback = nil
            @gtkWidgetRemovedFromCallback = nil
	    end
	    
        # Declares that this widget is a main Window
        # Normally, this will get set for you if the widget you are
        # adding is derived from Gtk::Window.  But you can set it
        # explicitly for certain effects if you know what you are doing.
	    def isAMainWindow
	        @gtkWidgetMainWindow = self
	    end

        # When adding the widget, expand it to take up all the allocated
        # vertical height.
        def expandWidgetHeight
	        @gtkWidgetExpandHeight = true
        end

        # Returns true when the the widget should take up all the allocated
        # vertical height.
        def expandWidgetHeight?
            @gtkWidgetExpandHeight
        end

        # When adding the widget, expand it to take up all the allocated
        # horizontal width.
        def expandWidgetWidth
	        @gtkWidgetExpandWidth = true
        end
	
        # Returns true when the the widget should take up all the allocated
        # horizontal width.
        def expandWidgetWidth?
            @gtkWidgetExpandWidth
        end

        # Use this widget as a container for the passed widget.
        # Calls gtkAddWidget, which you must define on the object.
        # Normally this will simply call add() in the correct container.
        # Also calls show_all, which you must define on the object
        # (if it isn't already).
		def addToThisWidget(widget)
   		    if !widget.class.ancestors.include?(Gtk::Window)
    		    widget.gtkWidgetMainWindow = @gtkWidgetMainWindow
    			gtkAddWidget(widget)
    			if !isInTests?
            		show_all
                end
    	    else
    	        widget.isAMainWindow
    	        widget.set_transient_for(@gtkWidgetMainWindow)
    	        if !isInTests?
        		    widget.show_all
        		end
    	    end
		end

        # Remove the passed widget from this object.
        # Calls gtkRemoveWidget, which you must define on the object.
        # Normally this will simply call remove().
        # Also calls show_all, which you must define on the object
        # (if it isn't already).
        def removeFromThisWidget(widget)
            widget.gtkWidgetMainWindow = nil
   		    if !widget.class.ancestors.include?(Gtk::Window)   
                gtkRemoveWidget(widget)
                if !isInTests?
                    show_all
                end
            end
        end

        # Set a closure to be run when the widget has been
        # added.  The block must accept the container widget
        # as a parameter.
        def afterWidgetIsAdded(&block)
            @gtkWidgetAddedToCallback = block
        end

        # Set a closure to be run when the widget has been
        # removed.  The block must accept the container widget
        # as a parameter.
        def afterWidgetIsRemoved(&block)
            @gtkWidgetRemovedFromCallback = block
        end

		# This method is called after the widget has been
		# successfully added to another widget
		def widgetWasAddedTo(widget)
            if !@gtkWidgetAddedToCallback.nil?
                @gtkWidgetAddedToCallback.call(widget)
            end
		end
		
		# This method is called after the widget has been
		# successfully removed from another widget
		def widgetWasRemovedFrom(widget)
            if !@gtkWidgetRemovedFromCallback.nil?
                @gtkWidgetRemovedFromCallback.call(widget)
            end
		end

        # Helper method for testing.  If this method is redefined to
        # return true, then the items will not be shown on the screen.
        def isInTests?
            false
        end

        # Default method for adding a widget.  Simply logs an warning.
        # It does not add the widget.
        def gtkAddWidget(widget)
            Context::Log::warning("Context::Widget", 
                                  "Attempted to add a widget " +
                                  "to #{self.class} which doesn't define " +
                                  "gtkAddWidget(). Ignoring addition.")
        end

        def gtkRemoveWidget(widget)
            Context::Log::warning("Context::Widget", 
                                  "Attempted to remove a widget " +
                                  "from #{self.class} which doesn't define " +
                                  "gtkRemoveWidget(). Ignoring removal.")
        end
	end
end
