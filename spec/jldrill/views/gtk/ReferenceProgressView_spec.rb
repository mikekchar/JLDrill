require 'Context/Bridge'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/spec/StoryMemento'

module JLDrill::Gtk

	describe ReferenceProgressView do

        before(:all) do
            @story = JLDrill::StoryMemento.new("ReferenceProgressView")

            def @story.setup(type)
                super(type)
                @context = @mainContext.loadReferenceContext
                @view = @context.peekAtView
            end
        end

	    it "should update the progress bar when updated" do
	        @story.setup(JLDrill::Gtk)
	        @story.start
	        # Stop it from actually loading the dictionary
	        @story.context.should_receive(:runInBackground)
	        @story.mainContext.loadReference
	        fraction = 0.57
	        @story.view.progressWindow.progress.should_receive(:fraction=).with(fraction)
	        @story.view.update(fraction)
	        @story.context.exit
	        @story.shutdown
	    end
	
        it "should destroy the progress window when context exited" do
            @story.setup(JLDrill::Gtk)
	        @story.start
	        # Stop it from actually loading the dictionary
	        @story.context.should_receive(:runInBackground)
	        @story.mainContext.loadReference
            @story.view.should_receive(:destroy) do
                @story.view.progressWindow.destroy
            end
            @story.context.exit
            @story.shutdown
        end
        
	end
end
