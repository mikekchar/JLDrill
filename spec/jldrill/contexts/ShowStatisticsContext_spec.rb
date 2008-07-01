require 'jldrill/contexts/ShowStatisticsContext'
require 'Context/Bridge'

module JLDrill

	describe ShowStatisticsContext do

		before(:each) do
			@main = MainContext.new(Context::Bridge.new(JLDrill))
			@context = @main.showStatisticsContext
			@context.createViews
			@view = @context.mainView
			
    		def @context.createViews
	    	    # Use the previously set View
    		end
		end
		
        it "should be created by the main context" do
            @main.showStatisticsContext.should_not be_nil
        end
        
        it "should have a view" do
            @view.should_not be_nil
        end
        
        it "should not be able to create the context twice at once" do
            def @context.enter(parent)
                super(parent)
                if @numTimesEntered.nil?
                    @numTimesEntered = 1
                else
                    @numTimesEntered += 1
                end
            end
            def @context.numTimesEntered
                @numTimesEntered
            end
            @main.showStatistics
            @main.showStatistics
            @context.numTimesEntered.should be(1)
        end
	end
end
