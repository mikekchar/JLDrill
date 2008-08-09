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
	        @strategy.status.should be_eql("     0%")
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
	    
	    it "should only pick unseen items" do
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
    	    # And set all the rest to unseen
    	    @quiz.contents.bins[4].contents[1..9].all? do |vocab|
    	        vocab.status.seen == false
    	    end.should be(true)
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
	    
	    it "should be able to create problems of the correct level" do
	        vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 1/Level: 0/Position: 1/")
            vocab2 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 2/Level: 1/Position: 2/")
            vocab3 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 3/Level: 2/Position: 3/")
            
            problem1 = @strategy.createProblem(vocab1)
            problem2 = @strategy.createProblem(vocab2)
            problem3 = @strategy.createProblem(vocab3)
            problem1.should be_a_kind_of(ReadingProblem)
            problem2.should be_a_kind_of(KanjiProblem)
            problem3.should be_a_kind_of(MeaningProblem)
	    end
    
        it "should create MeaningProblems and KanjiProblems equally in bin 4" do
            vocab4 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 4/Level: 2/Position: 4/")
            meaning = 0
            kanji = 0
            error = false
            0.upto(999) do
                problem4= @strategy.createProblem(vocab4)
                if problem4.class == MeaningProblem
                    meaning += 1
                elsif problem4.class == KanjiProblem
                    kanji += 1
                else
                    error = true
                end
            end
            error.should_not be(true)
            rate = ((meaning * 100) / (meaning + kanji)).to_i
            # I suppose this might fail sometime.  But it's very unlikely
            # since we have 1000 trials.  If it fails often
            # then there is definitely a problem.
            rate.should be_close(50, 10)
        end

        it "should return -1 when asked to pick from empty bins" do
	        @strategy.randomBin(1..2).should be(-1)                    
        end
        
        it "should return -1 when asked to pick from an empty range of bins" do
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 1)            
	        @quiz.contents.add(vocab, 2)
	        @strategy.randomBin(2..1).should be(-1)
        end

        it "should not pick empty bins even if it was the last item" do
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @last = vocab
	        @quiz.contents.add(vocab, 1)
	        @quiz.contents.bins[0].empty?.should be(true)
	        @quiz.contents.bins[1].empty?.should be(false)
	        @quiz.contents.bins[2].empty?.should be(true)
	        @strategy.randomBin(0..1).should be(1)
	        @strategy.randomBin(1..2).should be(1)
        end

        it "should alternate between 2 full bins" do
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 0)
	        # bin 4 already has an item
	        sizes = [0,0,0,0,0]
	        0.upto(29) do
	            bin = @strategy.randomBin(0..4)
    	        sizes[bin] += 1
    	        @strategy.last = @quiz.contents.bins[bin][0]
    	    end
    	    sizes[1].should be(0)
    	    sizes[2].should be(0)
    	    sizes[3].should be(0)
    	    sizes[0].should be(15)
    	    sizes[4].should be(15)
        end
        
        it "should pick full bins in a binary decreasing fashion" do
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 0)
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 1)
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 2)
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 3)
	        # bin 4 already has an item
	        sizes = [0,0,0,0,0]
	        0.upto(999) do
	            bin = @strategy.randomBin(0..4)
    	        sizes[bin] += 1
    	        @strategy.last = @quiz.contents.bins[bin][0]
    	    end
    	    total = sizes[0] + sizes[1] + sizes[2] + sizes[3] + sizes[4]
    	    percent = [0,0,0,0,0]
    	    percent[0] = (sizes[0] * 100) / total
    	    percent[1] = (sizes[1] * 100) / total
    	    percent[2] = (sizes[2] * 100) / total
    	    percent[3] = (sizes[3] * 100) / total
    	    percent[4] = (sizes[4] * 100) / total
    	    percent[0].should be_close(50, 5)
    	    percent[1].should be_close(25, 5)
    	    percent[2].should be_close(12, 5)
    	    percent[3].should be_close(6, 5)
    	    percent[4].should be_close(6, 5)
        end
        
        it "should be able to tell if the working set is full" do
            @quiz.options.introThresh = 5
            @strategy.workingSetFull?.should be(false)
            vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 1)
            @strategy.workingSetFull?.should be(false)
	        @quiz.contents.add(vocab, 2)
            @strategy.workingSetFull?.should be(false)
	        @quiz.contents.add(vocab, 3)
            @strategy.workingSetFull?.should be(false)
	        @quiz.contents.add(vocab, 2)
            @strategy.workingSetFull?.should be(false)
            0.upto(10) do
    	        @quiz.contents.add(vocab, 0)
    	        @quiz.contents.add(vocab, 4)
    	    end
            @strategy.workingSetFull?.should be(false)
	        @quiz.contents.add(vocab, 1)
            @strategy.workingSetFull?.should be(true)
        end
        
        it "should be able to tell if the review set needs reviewing" do
            @quiz.options.introThresh = 5
            # There are only review set items.  So we should review.
            @strategy.shouldReview?.should be(true)
            
            vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 1)
            # Now there is a working set item, and we don't have enough items
            # in the review set, so we should not review
            @strategy.shouldReview?.should be(false)
            # Make a total of 5 items in the review set
            0.upto(3) do
              @quiz.contents.add(vocab, 4)
            end
            # We have enough items, and we haven't learned the review items
            # to the required level, so we should review
            @strategy.shouldReview?.should be(true)
            0.upto(9) do
                @strategy.stats.correct(vocab)
            end
            # Now we know the items well enough, so we shouldn't review
            @strategy.shouldReview?.should be(false)                        
        end
        
        it "should be able to pick a bin with contents if possible" do
            quiz = Quiz.new
            strategy = quiz.strategy
            quiz.options.introThresh = 5
            
            # We don't have any items, so getBin should fail
            strategy.getBin.should be(-1)
            vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/")
	        quiz.contents.add(vocab, 0)
	        
	        # We have only have an item in the new set
	        strategy.getBin.should be(0)
	        
	        # Move the item to the working set
	        strategy.promote(vocab)
	        strategy.getBin.should be(1)

	        quiz.contents.add(vocab, 0)
            # Now we have an item in the new set and an item in the working set
            # It should give us the new set since the working set isn't full	        
	        strategy.getBin.should be(0)
	        
	        # We don't have enough items in the review set, so sill we should
	        # get the new set
	        strategy.getBin.should be(0)
	        
            0.upto(5) do
                quiz.contents.add(vocab,4)
            end
            # Now we have enough items in the review set, so we should get it
	        strategy.getBin.should be(4)
	        
            0.upto(4) do
                quiz.contents.add(vocab,1)
            end
	        # Now the working set is full
	        strategy.getBin.should be(1)
        end
        
        it "should increment the vocabulary's difficulty when an item is incorrect" do
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 3/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 3)
	        @quiz.currentProblem = @strategy.createProblem(vocab)
	        vocab.status.difficulty.should be(0)
	        @strategy.incorrect
	        vocab.status.difficulty.should be(1)
        end
        
        it "should reset the difficulty when the vocab is demoted from the 4th bin" do
            @quiz.options.promoteThresh = 1
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 1/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 1)
	        @quiz.currentProblem = @strategy.createProblem(vocab)
	        @strategy.incorrect
	        @strategy.incorrect
	        @strategy.incorrect
            vocab.status.bin.should be(1)	        
	        vocab.status.difficulty.should be(3)
	        @strategy.correct
	        @strategy.correct
	        @strategy.correct
            vocab.status.bin.should be(4)	        
	        vocab.status.difficulty.should be(3)
	        @strategy.incorrect
            vocab.status.bin.should be(1)	        	        
	        vocab.status.difficulty.should be(0)        
        end
        
        it "should reset the consecutive counter on an incorrect answer" do
            @quiz.options.promoteThresh = 1
	        vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 1/Level: 0/Position: -1/Consecutive: 0/")
	        @quiz.contents.add(vocab, 1)
	        @quiz.currentProblem = @strategy.createProblem(vocab)
            vocab.status.bin.should be(1)
	        @strategy.correct
	        @strategy.correct
	        @strategy.correct
            vocab.status.bin.should be(4)
            # we only increase consecutive in the review set
            vocab.status.consecutive.should be(1)
	        @strategy.correct
	        @strategy.correct
	        @strategy.correct
            vocab.status.consecutive.should be(4)

            @strategy.incorrect
            vocab.status.bin.should be(1)
            vocab.status.consecutive.should be(0)
        end
    end
end
