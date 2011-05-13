require 'Context/Bridge'
require 'Context/Context'
require 'Context/Views/Gtk/PageView'

module Context::Gtk 

    class FakeView < Context::View
        class FakeWidget < Gtk::Button
            include Widget

            def initialize(name)
                super(name)
                setupWidget
            end
        end
        
        def initialize(context)
            super(context)
            @widget = FakeWidget.new("Button")
        end

        def getWidget
            @widget
        end
    end

	describe PageView do

		before(:each) do
		    @bridge = Context::Bridge.new(Context::Gtk)
			@context = Context::Context.new(@bridge)
			@view = @bridge.PageView.new(@context)
		end

		it "should have a widget when initialized" do
			@view.getWidget.should_not be_nil
		end
				
		it "should add widgets from another view when added" do
			newContext = mock("Context::Context")
			newView = FakeView.new(newContext)
			@view.getWidget().should_receive(:gtkAddWidget).with(newView.getWidget)
			@view.addView(newView)
		end

        it "should remove widgets from another view when removed" do
			oldContext = mock("Context::MainContext")
			oldView = FakeView.new(oldContext)
            @view.addView(oldView)
			@view.getWidget().should_receive(:gtkRemoveWidget).with(oldView.getWidget)
			@view.removeView(oldView)
		end
            
		it "should react to destroy signals" do
			@view.should_receive(:close)
			@view.emitDestroyEvent
		end
	end
end

