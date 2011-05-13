module Context

	# This is the abstract view class
	class View
		attr_reader :context
		def initialize(context)
			@context = context
		end
		
		def addView(view)
			myWidget = getWidget()
			if(myWidget != nil)
				newWidget = view.getWidget()
				if !newWidget.nil?
    				myWidget.addToThisWidget(newWidget)
    				newWidget.widgetWasAddedTo(myWidget)
    		    end
			end
            view.viewAddedTo(self)
		end
        
        # Override this method to do something when your view has been
        # added to another view.  Most useful for adding subviews
        def viewAddedTo(parent)
        end

        def removeView(view)
            view.removingViewFrom(self)
            myWidget = getWidget()
            if(myWidget != nil)
                oldWidget = view.getWidget()
                if !oldWidget.nil?
                    myWidget.removeFromThisWidget(oldWidget)
                    oldWidget.widgetWasRemovedFrom(myWidget)
                end
            end
        end

        # Override this method to do something when your view being
        # removed from another view.  Most useful for removing subviews
        def removingViewFrom(parent)
        end
		
		# Concrete classes should override this method
		def getWidget
			return nil
		end

	end
end
