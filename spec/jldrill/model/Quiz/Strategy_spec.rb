require 'jldrill/model/Quiz/Strategy'
require 'jldrill/model/Quiz/Contents'
require 'jldrill/model/Vocabulary'
require 'jldrill/model/Problem'
require 'jldrill/spec/SampleQuiz'

module JLDrill

	describe Strategy do
	
	    before(:each) do
	        @quiz = Quiz.new
	        @sampleQuiz = SampleQuiz.new
	        vocab = @sampleQuiz.sampleVocab
	        item = @quiz.contents.add(vocab, 4)
	        @quiz.currentProblem = ReadingProblem.new(item, @quiz)
	        @strategy = @quiz.strategy
	    end
	    
	    it "should be able to return the status" do
	        @strategy.status.should_not be_nil
	        @strategy.status.should be_eql("     0%")
	    end
	    
	    it "should increment the statistics if correct in bin 4" do
	        @quiz.currentProblem.item.status.bin.should be(4)
	        @strategy.stats.accuracy.should be(0)
	        @strategy.correct
	        @strategy.stats.accuracy.should be(100)
	    end

	    it "should decrement the statistics if incorrect in bin 4" do
	        @quiz.currentProblem.item.status.bin.should be(4)
	        @strategy.stats.accuracy.should be(0)
	        @strategy.correct
	        @strategy.stats.accuracy.should be(100)
	        @strategy.incorrect
	        @strategy.stats.accuracy.should be(50)	        
	    end
	    
	    it "should use the contents from the quiz" do
	        @strategy.contents.should be(@quiz.contents)
	    end

        # Adds a sample vocabulary to a bin in a position and returns the item
        def test_addItem(bin, position)
            item = Item.new(@sampleQuiz.sampleVocab)
            item.status.position = position
            @quiz.contents.addItem(item, bin)
            return item
        end
	    
	    it "should only pick unseen items" do
	        1.upto(9) do |i|
	            test_addItem(4, i)
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
    	    @quiz.contents.bins[4].contents[1..9].all? do |item|
    	        item.status.seen == false
    	    end.should be(true)
	    end
	    
	    it "should demote bin 0 items to bin 0 and reset the level to 0" do
	        # Demoting bin 0 items is non-sensical, but it should do
	        # something sensible anyway.
	        item = test_addItem(0, 1)
	        @strategy.demote(item)
	        item.status.bin.should be(0)
	        item.status.level.should be(0)
	    end

	    it "should demote other items to bin 1 and reset the level to 0" do
	        item = test_addItem(1, 1)
	        @strategy.demote(item)
	        item.status.bin.should be(1)
	        item.status.level.should be(0)

	        item = test_addItem(2, 2)
	        item.status.level = 1
	        @strategy.demote(item)
	        item.status.bin.should be(1)
	        item.status.level.should be(0)

	        item = test_addItem(3, 3)
	        item.status.level = 2
	        @strategy.demote(item)
	        item.status.bin.should be(1)
	        item.status.level.should be(0)

	        item = test_addItem(4, 4)
	        item.status.level = 2
	        @strategy.demote(item)
	        item.status.bin.should be(1)
	        item.status.level.should be(0)
	    end
	    
	    it "should be able to create problems of the correct level" do
	        item1 = Item.new(@sampleQuiz.sampleVocab)
	        item1.status.level = 0
	        item1.status.bin = 1
	        item2 = Item.new(@sampleQuiz.sampleVocab)
	        item2.status.level = 1
	        item2.status.bin = 2
	        item3 = Item.new(@sampleQuiz.sampleVocab)
	        item3.status.level = 2
	        item3.status.bin = 3
            
            problem1 = @strategy.createProblem(item1)
            problem2 = @strategy.createProblem(item2)
            problem3 = @strategy.createProblem(item3)
            problem1.should be_a_kind_of(ReadingProblem)
            problem2.should be_a_kind_of(KanjiProblem)
            problem3.should be_a_kind_of(MeaningProblem)
	    end
    
        it "should create MeaningProblems and KanjiProblems equally in bin 4" do
            vocab4 = @sampleQuiz.sampleVocab
            meaning = 0
            kanji = 0
            error = false
            0.upto(999) do
                item4 = Item.new(vocab4)
                item4.status.bin = 4
                problem4 = @strategy.createProblem(item4)
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

        
        it "should be able to tell if the working set is full" do
            @quiz.options.introThresh = 5
            @strategy.workingSetFull?.should be(false)
	        test_addItem(1, -1)
            @strategy.workingSetFull?.should be(false)
	        test_addItem(2, -1)
            @strategy.workingSetFull?.should be(false)
	        test_addItem(3, -1)
            @strategy.workingSetFull?.should be(false)
	        test_addItem(2, -1)
            @strategy.workingSetFull?.should be(false)
            0.upto(10) do
                test_addItem(0, -1)
                test_addItem(4, -1)
    	    end
            @strategy.workingSetFull?.should be(false)
            test_addItem(1, -1)
            @strategy.workingSetFull?.should be(true)
        end
        
        it "should be able to tell if the review set needs reviewing" do
            @quiz.options.introThresh = 5
            # There are only review set items.  So we should review.
            @strategy.shouldReview?.should be(true)
            
            item = test_addItem(1, -1)
            # Now there is a working set item, and we don't have enough items
            # in the review set, so we should not review
            @strategy.shouldReview?.should be(false)
            # Make a total of 4 items in the review set
            0.upto(3) do
                item = test_addItem(4, -1)
            end
            # We have enough items, and we haven't learned the review items
            # to the required level, so we should review
            @strategy.shouldReview?.should be(true)
            0.upto(9) do
                @strategy.stats.correct(item)
            end
            # Now we know the items well enough, so we shouldn't review
            @strategy.shouldReview?.should be(false)                        
        end
        
        it "should increment the item's difficulty when an item is incorrect" do
            item = test_addItem(4, -1)
	        @quiz.currentProblem = @strategy.createProblem(item)
	        item.status.difficulty.should be(0)
	        @strategy.incorrect
	        item.status.difficulty.should be(1)
        end
        
        # Originally the difficulty counter would reset when the item was demoted
        # from the 4th bin.  I decided this was a bad idea, so now it doesn't
        # reset it.  If you want to change it back, make sure to think it out
        # thoroughly so that we don't just go back and forth.
        it "should not reset the difficulty when the item is demoted from the 4th bin" do
            @quiz.options.promoteThresh = 1
            item = test_addItem(1, -1)
	        @quiz.currentProblem = @strategy.createProblem(item)
	        @strategy.incorrect
	        @strategy.incorrect
	        @strategy.incorrect
            item.status.bin.should be(1)	        
	        item.status.difficulty.should be(3)
	        @strategy.correct
	        @strategy.correct
	        @strategy.correct
            item.status.bin.should be(4)	        
	        item.status.difficulty.should be(3)
	        @strategy.incorrect
            item.status.bin.should be(1)	        	        
	        item.status.difficulty.should be(4)        
        end
        
        it "should reset the consecutive counter on an incorrect answer" do
            @quiz.options.promoteThresh = 1
            item = test_addItem(1, -1)
	        @quiz.currentProblem = @strategy.createProblem(item)
            item.status.bin.should be(1)
	        @strategy.correct
	        @strategy.correct
	        @strategy.correct
            item.status.bin.should be(4)
            # we only increase consecutive in the review set
            item.status.consecutive.should be(1)
	        @strategy.correct
	        @strategy.correct
	        @strategy.correct
            item.status.consecutive.should be(4)

            @strategy.incorrect
            item.status.bin.should be(1)
            item.status.consecutive.should be(0)
        end
    end
end
