require 'Context/Bridge'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/views/gtk/OptionsView'
require 'jldrill/spec/StoryMemento'

module JLDrill::Gtk

	describe MainWindowView do

        before(:all) do
            @story = JLDrill::StoryMemento.new("MainWindowView")
            def @story.setup(type)
                super(type)
                @context = @mainContext
                @view = @mainView
            end
        end

		it "should have a widget when initialized" do
		    @story.setup(JLDrill::Gtk)
		    @story.start
			@story.view.getWidget.should_not be_nil
			@story.shutdown
		end

		it "should react to destroy signals" do
		    @story.setup(JLDrill::Gtk)
		    @story.start
			@story.view.should_receive(:close) do
			    @story.context.exit
			end
			@story.view.emitDestroyEvent
			@story.restart
		end
 
        it "should be able to add items to the end of the window" do
            @story.setup(JLDrill::Gtk)
		    @story.start
            @story.view.mainWindow.contents.children.size.should be(3)
            sb = Gtk::Statusbar.new
            widget = Context::Gtk::Widget.new(sb)
            @story.view.getWidget.add(widget)
            @story.view.mainWindow.contents.children.size.should be(4)            
            @story.shutdown
        end
        
        it "should be able to remove items from the window" do
            @story.setup(JLDrill::Gtk)
		    @story.start
            @story.view.mainWindow.contents.children.size.should be(3)
            sb = Gtk::Statusbar.new
            widget = Context::Gtk::Widget.new(sb)
            @story.view.getWidget.add(widget)
            @story.view.mainWindow.contents.children.size.should be(4)
            @story.view.getWidget.remove(widget)                    
            @story.view.mainWindow.contents.children.size.should be(3)
            @story.shutdown
        end	
	end
end
