require 'Context/Bridge'
require 'jldrill/contexts/GetFilenameContext'
require 'jldrill/views/gtk/FilenameSelectorView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'

module JLDrill::Gtk

	describe FilenameSelectorView do

		before(:each) do
		    bridge = Context::Bridge.new(JLDrill::Gtk)
		    @main = JLDrill::MainContext.new(bridge)
			@context = @main.getFilenameContext

            # Creates the main view and returns it
            def @context.peakAtView
                createViews
                @mainView
            end
			
			# Makes it so the view is only created if it isn't there
			# there already.  This allowed us to peak at the view
			# ahead of time.
    		def @context.createViews
    		    if @mainView.nil?
    		        super
    		    end
    		end
    		
    		# Make sure the main view is set to nil so that our
    		# createViews substitute works properly.
    		def @context.destroyViews
    		    @mainView = nil
    		end
		end

        # Overrides the method on the object with the closure
        # that's passed in.
        def override_method(object, method, &block)
            class << object
                self
            end.send(:define_method, method, &block)
        end
		
		# Set up for context.enter.  Returns the view that will be used
		def test_getViewForEnter
            mainViewWidget = @main.mainView.getWidget
            view = @context.peakAtView
			view.selectorWindow.should_receive(:set_transient_for).with(mainViewWidget.delegate)
			view.selectorWindow.should_receive(:show_all)
			view
		end

        # Make the modal dialog run as if the OK button was pressed.	
	    def test_runOK(view)
            override_method(view.selectorWindow, :run) do
                Gtk::Dialog::RESPONSE_ACCEPT
            end	    
	    end
				
        # Make the modal dialog run as if the OK button was pressed.	
	    def test_runCANCEL(view)
            override_method(view.selectorWindow, :run) do
                Gtk::Dialog::RESPONSE_CANCEL
            end	    
	    end
				
		it "should open a options window transient on the main window when opened" do
            view = test_getViewForEnter
            test_runOK(view)
            @context.enter(@main)
		end

        it "should automatically exit the context after entry" do
            view = test_getViewForEnter
            test_runOK(view)
            @context.should_receive(:exit)
            @context.enter(@main)
        end

		it "should destroy the selectorWindow when it closes" do
            view = test_getViewForEnter
            test_runOK(view)
			view.selectorWindow.should_receive(:destroy)
			# Note: The context automatically exits after entry
            @context.enter(@main)
		end

        it "should set the filename and directory on OK" do
            view = test_getViewForEnter
            selectorWindow = view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
            test_runOK(view)
            @context.enter(@main).should be_eql("file")
            view.filename.should be_eql("file")
            view.directory.should be_eql("folder")
        end
        
        it "should not set the filename and directory on CANCEL" do
            view = test_getViewForEnter
            selectorWindow = view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
            test_runCANCEL(view)
            @context.enter(@main).should be_nil
            view.filename.should be_nil
            view.directory.should be_nil
        end

# This test doesn't work because the current_folder in the
# GTK object isn't a real property.  I can't think of any way to
# fix it.        
#        it "should default to the currently set directory" do
#            view = test_getViewForEnter
#            view.directory = File.join(JLDrill::Config::DATA_DIR, "quiz")
#            print "#{view.directory}\n"
#            test_runOK(view)
#            @context.enter(@main)
#            print "#{view.directory}\n"
#            view.directory.should be_eql(File.join(JLDrill::Config::DATA_DIR, "quiz"))
#        end
     
	end
end
