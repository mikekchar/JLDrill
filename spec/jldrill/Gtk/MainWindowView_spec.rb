require 'Gtk/MainWindowView.rb'

module JLDrill::Gtk 

	describe MainWindowView do

		before(:each) do
			@context = mock("Gtk::MainContext")
			@view = MainWindowView.new(@context)
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
			newView = MainWindowView.new(newContext)
			@view.getWidget().should_receive(:add).with(newView.getWidget)
			@view.addView(newView)
		end

		it "should react to destroy signals" do
			@view.should_receive(:close)
			@view.emitDestroyEvent
		end
	end
end
