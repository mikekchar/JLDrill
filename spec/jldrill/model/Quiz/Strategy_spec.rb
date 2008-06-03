require 'jldrill/model/Quiz/Strategy'
require 'jldrill/model/Quiz/Contents'
require 'jldrill/model/Vocabulary'
require 'jldrill/model/Problem'

module JLDrill

	describe Strategy do
	
	    before(:each) do
	        @quiz = Quiz.new
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 4/Level: 0/Position: 0/Consecutive: 0/")
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

        def test_addVocab(bin, position)
       	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: #{bin}/Level: 0/Position: #{position}/Consecutive: 0/")
    	        @quiz.contents.add(vocab, bin)
    	        vocab
        end
	    
	    it "should only pick unseen items in bin 4" do
	        1.upto(9) do |i|
	            test_addVocab(4, i)
    	    end
    	    @strategy.findUnseen(4).should be(0)
    	    @quiz.contents.bins[4][0].status.seen = true
    	    @strategy.findUnseen(4).should be(1)
    	    @quiz.contents.bins[4][1].status.seen = true
    	    @strategy.findUnseen(4).should be(2)
    	    0.upto(9) do |i|
        	    @quiz.contents.bins[4][i].status.seen = true
            end
            # When they are all seen, it should wrap
    	    @strategy.findUnseen(4).should be(0)
	    end
	    
	    it "should demote bin 0 items to bin 0 and reset the level to 0" do
	        # Demoting bin 0 items is non-sensical, but it should do
	        # something sensible anyway.
	        vocab = test_addVocab(0, 1)
	        @strategy.demote(vocab)
	        vocab.status.bin.should be(0)
	        vocab.status.level.should be(0)
	    end

	    it "should demote other items to bin 1 and reset the level to 0" do
	        vocab = test_addVocab(1, 1)
	        @strategy.demote(vocab)
	        vocab.status.bin.should be(1)
	        vocab.status.level.should be(0)

	        vocab = test_addVocab(2, 2)
	        vocab.status.level = 1
	        @strategy.demote(vocab)
	        vocab.status.bin.should be(1)
	        vocab.status.level.should be(0)

	        vocab = test_addVocab(3, 3)
	        vocab.status.level = 2
	        @strategy.demote(vocab)
	        vocab.status.bin.should be(1)
	        vocab.status.level.should be(0)

	        vocab = test_addVocab(4, 4)
	        vocab.status.level = 2
	        @strategy.demote(vocab)
	        vocab.status.bin.should be(1)
	        vocab.status.level.should be(0)

	    end

    end
end
