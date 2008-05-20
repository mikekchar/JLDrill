require 'jldrill/model/Quiz/Strategy'

module JLDrill

	describe Strategy do
	
	    before(:each) do
	        @quiz = Quiz.new
	        @strategy = @quiz.strategy
	    end
	    
	    it "should be able to return the status" do
	        @strategy.status.should_not be_nil
	        @strategy.status.should be_eql("Known: 0%")
	    end
	    
	    it "should increment the statistics if correct" do
	        @strategy.stats.accuracy.should be(0)
	        @strategy.correct
	        @strategy.stats.accuracy.should be(100)
	    end

	    it "should decrement the statistics if incorrect" do
	        @strategy.stats.accuracy.should be(0)
	        @strategy.correct
	        @strategy.stats.accuracy.should be(100)
	        @strategy.incorrect
	        @strategy.stats.accuracy.should be(50)	        
	    end
	    
	    it "should use the contents from the quiz" do
	        @strategy.contents.should be(@quiz.contents)
	    end
    end
end
