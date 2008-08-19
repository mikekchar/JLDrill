require 'Context/Bridge'
require 'jldrill/contexts/GetFilenameContext'
require 'jldrill/views/gtk/FilenameSelectorView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/spec/StoryMemento'

module JLDrill::Gtk

	describe FilenameSelectorView do

        before(:all) do
            @story = JLDrill::StoryMemento.new("FilenameSelectorView")
            @OK = Gtk::Dialog::RESPONSE_ACCEPT
            @CANCEL = Gtk::Dialog::RESPONSE_CANCEL

            def @story.setup(type)
                super(type)
                @context = @mainContext.getFilenameContext
                @view = @context.peekAtView
            end
        end

        it "should automatically exit the context after entry" do
            @story.setup(JLDrill::Gtk)
            @story.start
            @story.context.should_receive(:exit)
			@story.enterAndPressButton(@story.view.selectorWindow, @OK)
            @story.shutdown
        end

		it "should destroy the selectorWindow when it closes" do
            @story.setup(JLDrill::Gtk)
            @story.start
			@story.view.should_receive(:destroy) do
			    @story.view.selectorWindow.destroy
			end
			# Note: The context automatically exits after entry
			@story.enterAndPressButton(@story.view.selectorWindow, @OK)
            @story.shutdown
		end

        it "should set the filename and directory on OK" do
            @story.setup(JLDrill::Gtk)
            @story.start
            selectorWindow = @story.view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
			@story.enterAndPressButton(@story.view.selectorWindow, @OK)
            @story.view.filename.should be_eql("file")
            @story.view.directory.should be_eql("folder")
            @story.shutdown
        end
        
        it "should not set the filename and directory on CANCEL" do
            @story.setup(JLDrill::Gtk)
            @story.start
            selectorWindow = @story.view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
			@story.enterAndPressButton(@story.view.selectorWindow, @CANCEL)
            @story.view.filename.should be_nil
            @story.view.directory.should be_nil
            @story.shutdown
        end

	end
end
