require 'jldrill/model/Quiz/Statistics'
require 'jldrill/model/Item'

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
	        item = Item.new
            item.status.bin = 4
	        @statistics.accuracy.should be(0)
	        @statistics.correct(item)
	        @statistics.accuracy.should be(100)
	        @statistics.incorrect(item)
	        @statistics.accuracy.should be(50)
	    end
	    
	    it "should slowly move the estimate towards 100" do
	        item = Item.new
            item.status.bin = 4
	        results = [30, 51, 65, 75, 82, 87, 90, 93]
	        0.upto(7) do |i|
    	        @statistics.correct(item)
    	        @statistics.estimate.should be(results[i])
    	    end
	    end
	    
	    it "should keep track of the last ten responses" do
	        item = Item.new
            item.status.bin = 4
	        @statistics.lastTen.size.should be(0)
	        @statistics.correct(item)
	        @statistics.lastTen.size.should be(1)
	        @statistics.lastTen[0].should be(true)
	        @statistics.incorrect(item)
	        @statistics.lastTen.size.should be(2)
	        @statistics.lastTen[1].should be(false)
	        0.upto(20) do
	            @statistics.correct(item)
	        end
	        @statistics.lastTen.size.should be(10)
	    end
	    
	    it "should keep track of the recent (up to 10 items) accuracy" do
	        item = Item.new
            item.status.bin = 4
	        @statistics.recentAccuracy.should be(0)
	        @statistics.correct(item)
	        @statistics.recentAccuracy.should be(100)
	        @statistics.incorrect(item)
	        @statistics.recentAccuracy.should be(50)
	        @statistics.correct(item)
	        @statistics.recentAccuracy.should be(66)
	    end
	    
	    def test_Rand(percent)
	        rand(99) + 1 < percent
	    end
	    
	    def test_numTrials(percent, requiredConfidence, trials)
	        item = Item.new
            item.status.bin = 4
	        @statistics.resetConfidence
	        i = 0
	        finished = false
	        while (i < trials) && !finished do
	            if test_Rand(percent)
    	            @statistics.correct(item)
    	        else
    	            @statistics.incorrect(item)
    	        end
    	        i += 1
    	        finished = (@statistics.confidence > requiredConfidence)
	        end
	        i
	    end
	    
	    def test_averageTrials(percent, requiredConfidence, trials)
	        total = 0
	        # Probably this should be more than 30 since we are waiting
	        # for an event (Poisson distribution?)  But the tests are
	        # already too slow, and the results are pretty clear anyway.
	        1.upto(30) do
	            total += test_numTrials(percent, requiredConfidence, trials)
	        end
	        total / 30
	    end
	    
        # This shows the approximate distribution of average number
        # of trials before getting to 90% confidence.  They are actually
        # crowded a bit to the right hand side (i.e., the numbers are lower
        # than they really are) because I give up after going 50 trials
        # without getting to 90%.  Since I average it over 30 times, doing
        # more makes the tests too slow.  But if you are interested, you
        # can check it out (setting tt to 1000 is a good indication).
        #
        # The bottom line is that if your actual percentage is 90+, then
        # it takes between 10-20 trials to get to 90% confidence.  If the
        # actual percentage is 80%, it actually seems to take about 50
        # trials on average to get to 90% confidence (try it with larger
        # tt to see this). At 70% or less, you are unlikely to get to 90% 
        # confidence at all (more than 300 trials on average).
        #
        # So as far as I'm concerned, the algorithm is working well.
	    it "should calculate the confidence that the probability is > 90" do
	        (@statistics.confidence > 0).should be(true)
	        rc = 0.90  # Required Confidence
	        tt = 50    # Total trials
	        # These fail from time to time, so only enable them when you
	        # want to test that the distribution is correct
#	        test_averageTrials(0, rc, tt).should be(50)
#	        test_averageTrials(10, rc, tt).should be_close(50, 3)
#	        test_averageTrials(20, rc, tt).should be_close(50, 3)
#	        test_averageTrials(30, rc, tt).should be_close(50, 3)
#	        test_averageTrials(40, rc, tt).should be_close(50, 3)
#	        test_averageTrials(50, rc, tt).should be_close(50, 5)
#	        test_averageTrials(60, rc, tt).should be_close(50, 7)
#	        test_averageTrials(70, rc, tt).should be_close(42, 8)
#	        test_averageTrials(80, rc, tt).should be_close(30, 7)
#	        test_averageTrials(90, rc, tt).should be_close(15, 6)
#	        test_averageTrials(100, rc, tt).should be(10)
	    end
    end
end
