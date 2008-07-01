require 'Context/Bridge'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/views/gtk/StatisticsView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'

module JLDrill::Gtk

	describe StatisticsView do

		before(:each) do
		    bridge = Context::Bridge.new(JLDrill::Gtk)
		    @main = JLDrill::MainContext.new(bridge)
			@context = @main.showStatisticsContext
			@context.createViews
			@view = @context.mainView
			
    		def @context.createViews
	    	    # Use the previously set View
    		end
		end

		it "should have a widget when initialized" do
			@view.getWidget.should_not be_nil
		end
				
		it "should open a window transient on the main window when opened" do
            mainViewWidget = @main.mainView.getWidget
			@view.statisticsWindow.should_receive(:set_transient_for).with(mainViewWidget.delegate)
			@view.statisticsWindow.should_receive(:show_all)
            @context.enter(@main)
		end
	
        it "should close the view when the window is destroyed" do
            @view.should_receive(:close)
            @view.emitDestroyEvent
        end
        
	end
end
