require 'jldrill/views/StatisticsView'
require 'Context/Bridge'
require 'jldrill/contexts/ShowStatisticsContext'


module JLDrill

	describe StatisticsView do
	
	    before(:each) do
			@context = JLDrill::ShowStatisticsContext.new(Context::Bridge.new(JLDrill))
	        @context.createViews
	        @view = @context.mainView
	    end
	    
        it "should be able to update the statistics in the view" do
            # Please implement
        end
        
        it "should exit the context when the view is closed" do
            @context.should_receive(:exit)
            @view.close
        end
        
    end
end
