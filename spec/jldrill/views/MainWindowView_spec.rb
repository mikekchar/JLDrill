require 'jldrill/views/MainWindowView'
require 'Context/Bridge'
require 'jldrill/contexts/MainContext'


module JLDrill

	describe MainWindowView do
	
	    before(:each) do
			@context = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
	        @view = MainWindowView.new(@context)
	    end
	    
	    it "should contact the context in order to show statistics" do
	        @context.should_receive(:showStatistics)
	        @view.showStatistics
        end
    end
end
