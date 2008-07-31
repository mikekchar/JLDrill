require 'Context/Bridge'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/views/gtk/StatisticsView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/model/Quiz/Quiz'


module JLDrill::Gtk

	describe StatisticsView do

		class StatisticsViewStoryMemento
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
                @context = @mainContext.showStatisticsContext
                @view = @context.peekAtView
                @context.enter(@mainContext)
            end
 
            # Useful for shutting down when you are testing the view's response
            # to destroy messages.           
            def clearView
                @view = nil
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
            @story = StatisticsViewStoryMemento.new
        end

        it "should close the view when the window is destroyed" do
            @story.setup
            @story.view.should_receive(:close) do
                @story.view.statisticsWindow.destroy
            end
            @story.view.emitDestroyEvent
            @story.clearView
            @story.context.exit
            @story.shutdown
        end
        
	end
end
