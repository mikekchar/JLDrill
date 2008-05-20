require 'jldrill/model/Quiz/Statistics'

module JLDrill

	describe Statistics do
	
	    before(:each) do
	        @statistics = Statistics.new
	    end
	    
	    it "should start with an estimate of 0" do
	        @statistics.estimate.should be(0)
	        @statistics.accuracy.should be(0)
	    end
	    
	    it "should have an accuracy of 100 if all are correct" do
	        @statistics.correct = 42
	        @statistics.incorrect = 0
	        @statistics.accuracy.should be(100)
	    end
	    
	    it "should set the accuracy correctly" do
	        @statistics.accuracy.should be(0)
	        @statistics.correct 
	        @statistics.accuracy.should be(100)
	        @statistics.incorrect
	        @statistics.accuracy.should be(50)
	    end
	    
	    it "should slowly move the estimate towards 100" do
	        results = [30, 51, 65, 75, 82, 87, 90, 93]
	        0.upto(7) do |i|
    	        @statistics.correct
    	        @statistics.estimate.should be(results[i])
    	    end
	    end
    end
end
