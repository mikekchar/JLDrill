require 'Context/ViewFactory'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'

module JLDrill::Gtk

	describe MainWindowView do

		before(:each) do
			@context = JLDrill::MainContext.new(Context::ViewFactory.new(JLDrill::Gtk))
			@view = @context.mainView
		end

		it "should have a widget when initialized" do
			@view.getWidget.should_not be_nil
		end
				
		it "should show the widgets when opened" do
			@view.mainWindow.should_receive(:show_all)
			@view.open
		end
		
		it "should add widgets from another view when added" do
			newContext = mock("Gtk::MainContext")
			newView = JLDrill::Gtk::MainWindowView.new(newContext)
			@view.getWidget().should_receive(:add).with(newView.getWidget)
			@view.addView(newView)
		end

        it "should remove widgets from another view when removed" do
			oldContext = mock("Gtk::MainContext")
			oldView = JLDrill::Gtk::MainWindowView.new(oldContext)
			@view.getWidget().should_receive(:remove).with(oldView.getWidget)
			@view.removeView(oldView)
		end
            
		it "should react to destroy signals" do
			@view.should_receive(:close)
			@view.emitDestroyEvent
		end
	end
end
