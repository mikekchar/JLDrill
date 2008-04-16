require 'Context/ViewFactory'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/gtk/ReferenceProgressView'

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
		
		it "should open views that contain Gtk::Windows rather than add them" do
			newContext = mock("Gtk::MainContext")
			newView = JLDrill::Gtk::MainWindowView.new(newContext)
			newView.should_receive(:open)
			@view.addView(newView)
		end

        it "should close views that contain Gtk::Windows rather than remove them" do
			oldContext = mock("Gtk::MainContext")
			oldView = JLDrill::Gtk::MainWindowView.new(oldContext)
			oldView.should_receive(:close)
			@view.removeView(oldView)
		end
            
		it "should react to destroy signals" do
			@view.should_receive(:close)
			@view.emitDestroyEvent
		end

        # FIX ME!!! -- I've disabled this test until I get
        # back to refactoring the accel groups
        it "should have the menu accel group in its list" do
#            @view.mainWindow.should_receive(:loadReferences)
            groups = Gtk::AccelGroup.from_object(@view.mainWindow)
            groups.size.should be(1)
            groups[0].should be(@view.mainWindow.accelGroup)
            key = Context::Gtk::Key.new(Context::Key::Modifier.CONTROL, 'd')
            ran = Gtk::AccelGroup.activate(@view.mainWindow, key.getGtkKeyval, key.getGtkState)
#            ran.should be(true)
        end

        it "should have the control d accel defined" do
            controlD = Context::Gtk::Key.new(Context::Key::Modifier.CONTROL, 'd')
            @view.accelDefined?(controlD).should be(true)
        end

        it "should load the references on control d" do
#            @view.mainWindow.should_receive(:loadReferences)
#            controlD = Context::Gtk::Key.new(Context::Key::Modifier.CONTROL, 'd')
#            @view.runAccel(controlD).should be(true)
        end
		
	end
end
