require 'Context/Bridge'
require 'jldrill/contexts/GetFilenameContext'
require 'jldrill/views/gtk/FilenameSelectorView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/spec/Fakes'

module JLDrill::Gtk

	describe FilenameSelectorView do
	
	    class FilenameSelectorViewStoryMemento
            attr_reader :mainContext, :mainView, :context, :view
        
            def initialize
                restart
            end
            
            def restart
                @app = nil
                @mainContext = nil
                @mainView = nil
                @context = nil
                @view = nil
            end
            
            # Some useful routines
            def setup
                @app = JLDrill::Fakes::App.new(nil)
                @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill::Gtk))
                @mainContext.enter(@app)
                @mainView = @mainContext.mainView
                @context = @mainContext.getFilenameContext
                @view = @context.peekAtView
            end
            
            # This is very important to call when using setup because otherwise
            # you will leave windows hanging open.
            def shutdown
                @view.close unless @view.nil?
                @mainView.close unless @mainView.nil?
                restart
            end

            # Overrides the method on the object with the closure
            # that's passed in.
            def override_method(object, method, &block)
                class << object
                    self
                end.send(:define_method, method, &block)
            end

            # Make the modal dialog run as if the OK button was pressed.	
	        def enterAndPressOK
                override_method(@view.selectorWindow, :run) do
                    Gtk::Dialog::RESPONSE_ACCEPT
                end
                @context.enter(@mainContext)
	        end

            # Make the modal dialog run as if the CANCEL button was pressed.	
	        def enterAndPressCANCEL
                override_method(@view.selectorWindow, :run) do
                    Gtk::Dialog::RESPONSE_CANCEL
                end
                @context.enter(@mainContext)
	        end
        end
        
        before(:all) do
            @story = FilenameSelectorViewStoryMemento.new
        end

        it "should automatically exit the context after entry" do
            @story.setup
            @story.context.should_receive(:exit)
            @story.enterAndPressOK
            @story.shutdown
        end

		it "should destroy the selectorWindow when it closes" do
		    @story.setup
			@story.view.should_receive(:destroy) do
			    @story.view.selectorWindow.destroy
			end
			# Note: The context automatically exits after entry
			@story.enterAndPressOK
			@story.mainContext.exit
			@story.restart
		end

        it "should set the filename and directory on OK" do
            @story.setup
            selectorWindow = @story.view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
            @story.enterAndPressOK
            @story.view.filename.should be_eql("file")
            @story.view.directory.should be_eql("folder")
            @story.shutdown
        end
        
        it "should not set the filename and directory on CANCEL" do
            @story.setup
            selectorWindow = @story.view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
            @story.enterAndPressCANCEL
            @story.view.filename.should be_nil
            @story.view.directory.should be_nil
            @story.shutdown
        end

	end
end
