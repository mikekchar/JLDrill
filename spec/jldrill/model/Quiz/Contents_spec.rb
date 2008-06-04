require 'jldrill/model/Quiz/Contents'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/model/Vocabulary'

module JLDrill

	describe Contents do
	
	    before(:each) do
	        @quiz = Quiz.new
	    end
	    
	    it "should indicate if a range of bins has contents" do
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 4/Level: 0/Position: 0/Consecutive: 0/")
	        @quiz.contents.add(vocab, 4)
	        @quiz.contents.rangeEmpty?(4..4).should be(false)
        end
                
        # Do I really use this functionality???
        # FIXME
        it "should add items to the last position if the position is set to -1" do
        	vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 4/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 4)
	        @quiz.contents.bins[4][0].status.position.should be(0)
	    end
	    
	    it "should be able to print out the status" do
	        sizes = [0,0,0,0,0]
	        0.upto(4) do |bin|
	            1.upto(rand(10)) do |size| 
                	vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: #{bin}/Level: 0/Position: -1/Consecutive: 0/")
        	        @quiz.contents.add(vocab, bin)
        	        sizes[bin] = size
        	    end
    	    end
    	    @quiz.contents.status.should be_eql("Level U: #{sizes[0]} P: #{sizes[1]} F: #{sizes[2]} G: #{sizes[3]} E: #{sizes[4]}")
	    end
    end
end
