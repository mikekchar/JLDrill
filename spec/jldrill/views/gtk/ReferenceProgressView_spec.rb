require 'Context/Bridge'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'

module JLDrill::Gtk

	describe ReferenceProgressView do

		class ReferenceProgressViewStoryMemento
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
                @context = @mainContext.loadReferenceContext
                @view = @context.peekAtView
			    @context.should_receive(:loadInBackground)
                @context.enter(@mainContext)
            end
            
            def getNewView
                @view = @context.peekAtView
            end
            
            # This is very important to call when using setup because otherwise
            # you will leave windows hanging open.
            def shutdown
                @view.close unless @view.nil?
                @mainView.close unless @mainView.nil?
                restart
            end
        end
        
        before(:all) do
            @story = ReferenceProgressViewStoryMemento.new
        end

	    it "should update the progress bar when updated" do
	        @story.setup
	        fraction = 0.57
	        @story.view.progressWindow.progress.should_receive(:fraction=).with(fraction)
	        @story.view.update(fraction)
	        @story.context.exit
	        @story.shutdown
	    end
	
        it "should destroy the progress window when context exited" do
            @story.setup
            @story.view.should_receive(:destroy) do
                @story.view.progressWindow.destroy
            end
            @story.context.exit
            @story.shutdown
        end
        
	end
end
