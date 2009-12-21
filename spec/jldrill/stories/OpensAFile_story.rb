require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/GtkStoryFunctionality'
require 'jldrill/contexts/GetFilenameContext'

module JLDrill::OpensAFile
    class MyStory < JLDrill::StoryMemento
        include JLDrill::StoryFunctionality::Gtk
    end

	Story = MyStory.new("JLDrill opens a file.")

	def Story.setup(type)
		super(type)
        @context = @mainContext.getFilenameContext
        @view = @context.peekAtView
	end

	describe Story.stepName("Gets the filename from the user") do
		before(:each) do
			Story.setup(JLDrill::Gtk)
			Story.start
		end

		after(:each) do
			Story.shutdown
		end

        it "should automatically exit the context after entry" do
            Story.context.should_receive(:exit)
			Story.enterDialogAndPressOK(Story.view.selectorWindow)
        end

		it "should destroy the selectorWindow when it closes" do
			Story.view.should_receive(:destroy) do
			    Story.view.selectorWindow.destroy
			end
			# Note: The context automatically exits after entry
			Story.enterDialogAndPressOK(Story.view.selectorWindow)
		end

        it "should set the filename and directory on OK" do
            selectorWindow = Story.view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
			Story.enterDialogAndPressOK(Story.view.selectorWindow)
            Story.view.filename.should eql("file")
            Story.view.directory.should eql("folder")
        end
        
        it "should not set the filename and directory on CANCEL" do
            selectorWindow = Story.view.selectorWindow
            def selectorWindow.getFilename
                "file"
            end
            def selectorWindow.getCurrentFolder
                "folder"
            end
			Story.enterDialogAndPressCancel(Story.view.selectorWindow)
            Story.view.filename.should be_nil
            Story.view.directory.should be_nil
        end
    end
end
