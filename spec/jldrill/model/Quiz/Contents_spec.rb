require 'jldrill/model/Quiz/Contents'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/model/Vocabulary'
require 'jldrill/spec/SampleQuiz'

module JLDrill

	describe Contents do
	
	    before(:each) do
	        @sampleQuiz = SampleQuiz.new
	        @quiz = @sampleQuiz.quiz
	    end
	    
	    it "should indicate if a range of bins has contents" do
	        quiz = Quiz.new
	        vocab = @sampleQuiz.sampleVocab
	        quiz.contents.add(vocab, 4)
	        quiz.contents.rangeEmpty?(4..4).should be(false)
        end
                
        it "should add items to the last position if the position is set to -1" do
        	vocab = @sampleQuiz.sampleVocab
        	vocab.status.position.should be(-1)
	        @quiz.contents.bins[4].length.should be(2)
	        @quiz.contents.add(vocab, 4)
	        @quiz.contents.bins[4].length.should be(3)
	        # This is the 5th item counting from 0.  There are already 2
	        # items in bin 4, so it should put it at the end.
	        @quiz.contents.bins[4][2].status.position.should be(4)
	    end
	    
	    it "should be able to print out the status" do
    	    @quiz.contents.status.should be_eql("U: 1 P: 0 F: 1 G: 0 E: 2")
	    end
	    
	    def countSizes(sizes, range)
	        total = 0
	        range.each do |i|
	            total += sizes[i]
	        end
	        total
	    end
	    
	    it "should be able to count the unseen items in a range" do
	        quiz = Quiz.new
	        quiz.contents.numUnseen(0..4).should be(0)
	        
	        sizes = [0,0,0,0,0]
	        0.upto(4) do |bin|
	            1.upto(rand(10)) do |size| 
                	vocab = @sampleQuiz.sampleVocab
        	        quiz.contents.add(vocab, bin)
        	        sizes[bin] = size
        	    end
    	    end
    	    
    	    quiz.contents.numUnseen(0..4).should be(countSizes(sizes, 0..4))
    	    quiz.contents.numUnseen(0..0).should be(countSizes(sizes, 0..0))
    	    quiz.contents.numUnseen(4..4).should be(countSizes(sizes, 4..4))
    	    quiz.contents.numUnseen(2..3).should be(countSizes(sizes, 2..3))
    	    quiz.contents.numUnseen(1..3).should be(countSizes(sizes, 1..3))
	    end
	    
	    it "should be able to find the nth unseen item in the contents" do
	        quiz = Quiz.new
	        quiz.contents.numUnseen(0..4).should be(0)
	        quiz.contents.findUnseen(4, 0..4).should be_nil

	        0.upto(4) do |bin|
	            1.upto(5) do |size| 
                	vocab = @sampleQuiz.sampleVocab
        	        quiz.contents.add(vocab, bin)
        	    end
    	    end
    	    
    	    quiz.contents.findUnseen(0, 0..0).should be_eql(quiz.contents.bins[0][0])
    	    quiz.contents.findUnseen(0, 0..4).should be_eql(quiz.contents.bins[0][0])
    	    quiz.contents.findUnseen(0, 4..4).should be_eql(quiz.contents.bins[4][0])
    	    quiz.contents.findUnseen(4, 0..4).should be_eql(quiz.contents.bins[0][4])
    	    quiz.contents.findUnseen(5, 0..4).should be_eql(quiz.contents.bins[1][0])
    	    quiz.contents.findUnseen(4, 2..3).should be_eql(quiz.contents.bins[2][4])
    	    quiz.contents.findUnseen(5, 2..3).should be_eql(quiz.contents.bins[3][0])
    	    quiz.contents.findUnseen(12, 1..3).should be_eql(quiz.contents.bins[3][2])
            quiz.contents.bins[1][3].status.seen = true
    	    quiz.contents.findUnseen(12, 1..3).should be_eql(quiz.contents.bins[3][3])
    	    quiz.contents.findUnseen(15, 1..3).should be_nil
	    end
	    
	    it "should be able to add items to the contents only if they dont already exist" do
            newVocab = @sampleQuiz.sampleVocab
            @quiz.contents.addUniquely(newVocab).should be(true)
            newVocab.status.position.should be(4)

            # We just added this one
            existingVocab = @sampleQuiz.sampleVocab
            @quiz.contents.addUniquely(existingVocab).should be(false)
	    end
	    
	    it "should be able to add the contents from another quiz to this one" do
	        quiz2 = Quiz.new

            quiz2.loadFromString("testFile", @sampleQuiz.file)
            newVocab = @sampleQuiz.sampleVocab
            quiz2.contents.add(newVocab, 2)
            quiz2.contents.length.should be(5)
            quiz2.contents.bins[2][1].kanji.should be_eql(newVocab.kanji)
	        
	        @quiz.contents.addContents(quiz2.contents)
	        @quiz.contents.length.should be(5)
            @quiz.contents.bins[2][1].kanji.should be_eql(newVocab.kanji)
	    end

    end
end
