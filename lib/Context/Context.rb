# encoding: utf-8
module Context

    # The Context is the Presenter in the Model, View, Presentor (MVP)
    # model.  It is an object that holds the logic for the UI
    # scenario that the application is currently in.  Context is
    # an abstract class. 
    #
    # A Context is made up of views, model objects and other sub-contexts.
    # One of the views should be a UI widget container that contains all
    # of the views for the Context.  The concrete classes should define
    # the logic for the Context that is either called by enter()
    # or called from one of the contained views.
    #
    # Note that views are usually only instantiated in createViews, which
    # is called on enter(), not on Context creation.  However, there is
    # no requirement for this.
	class Context
		attr_reader :parent, :mainView, :viewBridge
		attr_writer :mainView

        # Create a new Context.  Takes a Bridge that is used to
        # create the View s in using the correct namespace.	
		def initialize(viewBridge)
			@parent = nil
			@mainView = nil
			@viewBridge = viewBridge
			@entered = false
            @onExitBlock = nil
		end

        # Creates the views for the context.  This method is called
        # automatically by enter() and probably should not be called otherwise.
	    # This method should be overriden by the concrete class.  It
	    # should instantiate all the views and set @mainView
	    def createViews
	        # Nothing to do here
	    end
	    
	    # This is intended to be private (how do I do that again?)
	    # Just so that it doesn't create a view if it is already created
	    def setupViews
	        if @mainView.nil?
	            createViews
	        end
	    end
	    
	    # Creates views and returns the main View.  This is intended
	    # to be used by test code where entering the context executes
	    # code and you need to know what the view will be ahead of time.
	    # I can think of no reason to use this in production code.
	    def peekAtView
	        setupViews
	        @mainView
	    end

        # Destroys the views for the context.  This method is called
        # automatically by exit() and probably should not be called otherwise.
	    # This method should be overriden by the concrete class.  It
	    # should destroy all the views and set @mainView to nil
	    def destroyViews
	        @mainView = nil
	    end
	
	    # Adds a view to the mainView
	    # Since the mainView is intended to be a UI container that contains
	    # all the views, this method is called by a sub-context's enter()
	    # method to allow the parent's mainView to contain the sub-context's
	    # views.
		def addView(view)
			@mainView.addView(view) unless @mainView.nil?
		end
		
		# Enters the Context.  After it is called, the Context is then
		# active and can be interacted with.  This method automatically
		# calls createViews() and adds the mainView to the parent's view.
		# 
		# Usually this method will be overriden by the concrete class.
		# However, it should be careful to call super() in the appropriate
		# place.
		def enter(parent)
			@parent = parent
			if (@parent != nil)
			    @entered = true
			    setupViews
				parent.addView(@mainView) unless @mainView.nil?
			end
		end
		
		# Returns true if the context has been entered, but not exited.
		# Returns false if the context has never been entered, or if
		# it has been entered and then exited.
		def isEntered?
		    @entered
		end

        # Set a block to be called when the context exits.
        # Often a context is exited by the result of some UI activity
        # at some unknown point in the future.  The caller of the context
        # may want to do something after the context exits.  This block
        # will be called at the end of the exit method.
        def onExit(&block)
            @onExitBlock = block
        end
		
		# Exits the Context.  After it is called, the context is no longer
		# active and can't be interacted with.  This method automatically
		# removes the mainView from the parent's view and calls destroyViews().
		#
		# Usually this method will be overriden by the concrete class.
		# However, it should be careful to call super() in the appropriate
		# place.
		def exit()
		    @entered = false
            if !@parent.nil? && !@parent.mainView.nil?
                @parent.mainView.removeView(@mainView) unless @mainView.nil?
            end
            destroyViews
            if !@onExitBlock.nil?
                @onExitBlock.call
            end
		end
		    
	end
end
