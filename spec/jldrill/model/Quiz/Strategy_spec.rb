require 'jldrill/model/Quiz/Strategy'
require 'jldrill/model/Quiz/Contents'
require 'jldrill/model/Vocabulary'
require 'jldrill/model/Problem'

module JLDrill

	describe Strategy do
	
	    before(:each) do
	        @quiz = Quiz.new
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 4)
	        @quiz.currentProblem = ReadingProblem.new(vocab)
	        @strategy = @quiz.strategy
	    end
	    
	    it "should be able to return the status" do
	        @strategy.status.should_not be_nil
	        @strategy.status.should be_eql("Known: 0%")
	    end
	    
	    it "should increment the statistics if correct in bin 4" do
	        @quiz.vocab.status.bin.should be(4)
	        @strategy.stats.accuracy.should be(0)
	        @strategy.correct
	        @strategy.stats.accuracy.should be(100)
	    end

	    it "should decrement the statistics if incorrect in bin 4" do
	        @quiz.vocab.status.bin.should be(4)
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
