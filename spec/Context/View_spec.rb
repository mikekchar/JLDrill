# encoding: utf-8
require 'Context/Spec'
require 'Context/View'

module Context::Spec::ViewStory

	describe Context::View do

		# Since this is an abstract class, we need to override getWidget with
		# something that does something
        def overrideGetWidget(view)
			def view.getWidget
			    @widget
			end
			def view.setWidget(widget)
			    @widget = widget
			end
        end

		before(:each) do
		    @context = double("Context")
			@view = Context::View.new(@context)
			@widget = double("Widget")
			
			# Override the getWidget method
			@view.getWidget.should be_nil
			overrideGetWidget(@view)
			@view.setWidget(@widget)
			@view.getWidget.should be(@widget) 
		end
		
		it "should set the context on creation" do
			@view.context.should be(@context)
		end

		it "should use the widgets to add a view" do
		    newView = Context::View.new(@context)
		    overrideGetWidget(newView)
		    newWidget = double("Widget")
		    newView.setWidget(newWidget)
		    
		    @widget.should_receive(:addToThisWidget).with(newWidget)
		    newWidget.should_receive(:widgetWasAddedTo).with(@widget)
		    @view.addView(newView)
		end

		it "should use the widgets to remove a view" do
		    oldView = Context::View.new(@context)
		    overrideGetWidget(oldView)
		    oldWidget = double("Widget")
		    oldView.setWidget(oldWidget)
		    
		    @widget.should_receive(:removeFromThisWidget).with(oldWidget)
		    oldWidget.should_receive(:widgetWasRemovedFrom).with(@widget)
		    @view.removeView(oldView)
		end
		
	end
end
