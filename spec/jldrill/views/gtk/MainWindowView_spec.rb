require 'Context/Bridge'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/views/gtk/OptionsView'
require 'jldrill/spec/Fakes'

module JLDrill::Gtk

	describe MainWindowView do

        class MainWindowViewStoryMemento
            attr_reader :context, :view
        
            def initialize
                restart
            end
            
            def restart
                @app = nil
                @context = nil
                @view = nil
            end
            
            # Some useful routines
            def setup
                @app = JLDrill::Fakes::App.new(nil)
                @context = JLDrill::MainContext.new(Context::Bridge.new(JLDrill::Gtk))
                @context.enter(@app)
                @view = @context.mainView
            end
            
            # This is very important to call when using setup because otherwise
            # you will leave windows hanging open.
            def shutdown
                @view.close unless @view.nil?
                restart
            end
        end

        before(:all) do
            @story = MainWindowViewStoryMemento.new
        end

		it "should have a widget when initialized" do
		    @story.setup
			@story.view.getWidget.should_not be_nil
			@story.shutdown
		end

		it "should react to destroy signals" do
		    @story.setup
			@story.view.should_receive(:close) do
			    @story.context.exit
			end
			@story.view.emitDestroyEvent
			@story.restart
		end
 
        it "should be able to processes special characters in the answer string" do
            @story.setup
            @story.view.mainWindow.processString("This is a test\\n").should be_eql("This is a test\n")
            # Shouldn't break on quotes
            @story.view.mainWindow.processString("This is a \"test\"\\n").should be_eql("This is a \"test\"\n")
            @story.shutdown
        end
        
        it "should be able to add items to the end of the window" do
            @story.setup
            @story.view.mainWindow.mainTable.n_rows.should be(5)
            sb = Gtk::Statusbar.new
            @story.view.mainWindow.add(sb)
            @story.view.mainWindow.mainTable.n_rows.should be(6)            
            @story.shutdown
        end
        
        it "should not be able to remove items from the window" do
            # OK.  This sucks, but the Gtk::Table has no way to
            # remove items (i.e., I shouldn't use it -- FIXME!!!)
            @story.setup
            @story.view.mainWindow.mainTable.n_rows.should be(5)
            sb = Gtk::Statusbar.new
            @story.view.mainWindow.add(sb)
            @story.view.mainWindow.mainTable.n_rows.should be(6)
            @story.view.mainWindow.remove(sb)                    
            @story.view.mainWindow.mainTable.n_rows.should be(6)
            @story.shutdown
        end
        
        it "should not be using a Gtk::Table because it raises an assertion on exit"

# FIX ME!!! -- I've disabled these test until I get
# back to refactoring the accel groups
        
        it "should have the menu accel group in its list" 
# do
#            @view.mainWindow.should_receive(:loadReferences)
#            groups = Gtk::AccelGroup.from_object(@view.mainWindow)
#            groups.size.should be(1)
#            groups[0].should be(@view.mainWindow.accelGroup)
#            key = Context::Gtk::Key.new(Context::Key::Modifier.CONTROL, 'd')
#            ran = Gtk::AccelGroup.activate(@view.mainWindow, key.getGtkKeyval, key.getGtkState)
#            ran.should be(true)
#        end

        it "should have the control d accel defined" 
#        do
#            controlD = Context::Gtk::Key.new(Context::Key::Modifier.CONTROL, 'd')
#            @view.accelDefined?(controlD).should be(true)
#        end

        it "should load the references on control d" 
#       do
#            @view.mainWindow.should_receive(:loadReferences)
#            controlD = Context::Gtk::Key.new(Context::Key::Modifier.CONTROL, 'd')
#            @view.runAccel(controlD).should be(true)
#        end
		
	end
end
