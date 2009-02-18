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
	end
end
