require 'Context/Bridge'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'

module JLDrill::Gtk

	describe ReferenceProgressView do

		before(:each) do
		    bridge = Context::Bridge.new(JLDrill::Gtk)
		    @main = JLDrill::MainContext.new(bridge)
			@context = @main.loadReferenceContext
			@view = @context.mainView
		end

		it "should have a widget when initialized" do
			@view.getWidget.should_not be_nil
		end
				
		it "should open a progress transient on the main window when opened" do
            mainViewWidget = @main.mainView.getWidget
			@view.progressWindow.should_receive(:set_transient_for).with(mainViewWidget.delegate)
			@view.progressWindow.should_receive(:show_all)
			@context.should_receive(:loadInBackground)
            @context.enter(@main)
		end
	
	    it "should update the progress bar when updated" do
	        fraction = 0.57
	        @view.progressWindow.progress.should_receive(:fraction=).with(fraction)
	        @view.update(fraction)
	    end
	
        it "should destroy the progress window when context exited" do
            mainViewWidget = @main.mainView.getWidget
			@view.progressWindow.should_receive(:set_transient_for).with(mainViewWidget.delegate)
			@view.progressWindow.should_receive(:show_all)
			@context.should_receive(:loadInBackground)
            @context.enter(@main)
            @view.progressWindow.should_receive(:destroy)
            @context.exit
        end
        
	end
end
