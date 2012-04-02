# encoding: utf-8
require 'jldrill/model/quiz/Strategy'
require 'jldrill/model/quiz/Contents'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/Problem'
require 'jldrill/model/problems/ProblemFactory'
require 'jldrill/spec/SampleQuiz'

module JLDrill

	describe Strategy do
	
	    before(:each) do
	        @quiz = Quiz.new
	        @sampleQuiz = SampleQuiz.new
	        vocab = @sampleQuiz.sampleVocab
	        item = @quiz.contents.add(vocab, Strategy.reviewSetBin)
	        @quiz.currentProblem = ReadingProblem.new(item)
	        @strategy = @quiz.strategy
	    end
	    
	    it "should be able to return the status" do
	        @strategy.status.should_not be_nil
	        @strategy.status.should be_eql("     0%")
	    end
	    
	    it "should increment the statistics if correct in review Set" do
	        @quiz.currentProblem.item.bin.should eql(Strategy.reviewSetBin)
	        @strategy.reviewStats.accuracy.should eql(0)
	        @strategy.correct(@quiz.currentProblem.item)
	        @strategy.reviewStats.accuracy.should eql(100)
	    end

	    it "should decrement the statistics if incorrect in review Set" do
	        @quiz.currentProblem.item.bin.should eql(Strategy.reviewSetBin)
	        @strategy.reviewStats.accuracy.should eql(0)
	        @strategy.correct(@quiz.currentProblem.item)
	        @strategy.reviewStats.accuracy.should eql(100)
	        @strategy.incorrect(@quiz.currentProblem.item)
	        @strategy.reviewStats.accuracy.should eql(50)	        
	    end
	    
	    it "should use the contents from the quiz" do
	        @strategy.contents.should eql(@quiz.contents)
	    end

        # Adds a sample vocabulary to a bin in a position and returns the item
        def test_addItem(bin, position)
            item = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
            item.position = position
            @quiz.contents.addItem(item, bin)
            return item
        end
	    
	    it "should only pick unseen items" do
	        1.upto(9) do |i|
	            test_addItem(Strategy.reviewSetBin, i)
    	    end
    	    @strategy.findUnseenIndex(Strategy.reviewSetBin).should eql(0)
    	    @quiz.contents.bins[Strategy.reviewSetBin][0].firstSchedule.seen = true
    	    @strategy.findUnseenIndex(Strategy.reviewSetBin).should eql(1)
    	    @quiz.contents.bins[Strategy.reviewSetBin][1].firstSchedule.seen = true
    	    @strategy.findUnseenIndex(Strategy.reviewSetBin).should eql(2)
    	    0.upto(9) do |i|
        	    @quiz.contents.bins[Strategy.reviewSetBin][i].firstSchedule.seen = true
            end
            # When they are all seen, it should wrap
    	    @strategy.findUnseenIndex(Strategy.reviewSetBin).should eql(0)
    	    # And set all the rest to unseen
    	    @quiz.contents.bins[Strategy.reviewSetBin].contents[1..9].all? do |item|
    	        item.firstSchedule.seen == false
    	    end.should eql(true)
	    end
	    
	    it "should demote new set items to new set" do
	        # Demoting new set items is non-sensical, but it should do
	        # something sensible anyway.
	        item = test_addItem(Strategy.newSetBin, 1)
	        @strategy.demote(item)
	        item.bin.should eql(Strategy.newSetBin)
	        item.firstSchedule.should be_nil
	    end

	    it "should demote other items to the working set" do
	        item = test_addItem(Strategy.workingSetBin, 1)
	        @strategy.demote(item)
	        item.bin.should eql(Strategy.workingSetBin)

	        item = test_addItem(Strategy.workingSetBin, 2)
	        @strategy.demote(item)
	        item.bin.should eql(Strategy.workingSetBin)

	        item = test_addItem(Strategy.workingSetBin, 3)
	        @strategy.demote(item)
	        item.bin.should eql(Strategy.workingSetBin)

	        item = test_addItem(Strategy.reviewSetBin, 4)
	        @strategy.demote(item)
	        item.bin.should eql(Strategy.workingSetBin)
	    end
	    
	    it "should be able to create problems of the correct level" do
            @quiz.options.promoteThresh = 1

	        item1 = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
	        item1.bin = Strategy.workingSetBin
            problemStatus = item1.status.select("ProblemStatus")
            problemStatus.checkSchedules
            problemStatus.findScheduleForLevel(0).should_not eql(nil)
            item1.firstSchedule.problemType.should eql("ReadingProblem")

	        item2 = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
	        item2.bin = Strategy.workingSetBin
            problemStatus = item2.status.select("ProblemStatus")
            problemStatus.checkSchedules
            problemStatus.findScheduleForLevel(1).should_not eql(nil)
            @quiz.strategy.correct(item2)
            item2.firstSchedule.problemType.should eql("KanjiProblem")
	        
	        item3 = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
	        item3.bin = Strategy.workingSetBin
            problemStatus = item3.status.select("ProblemStatus")
            problemStatus.checkSchedules
            problemStatus.findScheduleForLevel(2).should_not eql(nil)
            @quiz.strategy.correct(item3)
            @quiz.strategy.correct(item3)
            item3.firstSchedule.problemType.should eql("MeaningProblem")
            
            problem1 = @strategy.createProblem(item1)
            problem2 = @strategy.createProblem(item2)
            problem3 = @strategy.createProblem(item3)
            problem1.should be_a_kind_of(ReadingProblem)
            problem2.should be_a_kind_of(KanjiProblem)
            problem3.should be_a_kind_of(MeaningProblem)
	    end
    
        it "should be able to tell if the working set is full" do
            @quiz.options.introThresh = 5
            @strategy.workingSetFull?.should eql(false)
	        test_addItem(Strategy.workingSetBin, -1)
            @strategy.workingSetFull?.should eql(false)
	        test_addItem(Strategy.workingSetBin, -1)
            @strategy.workingSetFull?.should eql(false)
	        test_addItem(Strategy.workingSetBin, -1)
            @strategy.workingSetFull?.should eql(false)
	        test_addItem(Strategy.workingSetBin, -1)
            @strategy.workingSetFull?.should eql(false)
            0.upto(10) do
                test_addItem(Strategy.newSetBin, -1)
                test_addItem(Strategy.reviewSetBin, -1)
    	    end
            @strategy.workingSetFull?.should eql(false)
            test_addItem(Strategy.workingSetBin, -1)
            @strategy.workingSetFull?.should eql(true)
        end
        
        it "should be able to tell if the review set needs reviewing" do
            @quiz.options.introThresh = 5
            # There are only review set items.  So we should review.
            @strategy.shouldReview?.should eql(true)
            
            item = test_addItem(Strategy.workingSetBin, -1)
            # Now there is a working set item, and we don't have enough items
            # in the review set, so we should not review
            @strategy.shouldReview?.should eql(false)
            # Make a total of 4 items in the review set
            0.upto(3) do
                item = test_addItem(Strategy.reviewSetBin, -1)
            end
            # We have enough items, and we haven't learned the review items
            # to the required level, so we should review
            @strategy.shouldReview?.should eql(true)
            0.upto(9) do
                @strategy.reviewStats.correct(item)
            end
            # We don't start the countdown until we have reviewed 10 items
            # so we should continue to review
            @strategy.shouldReview?.should eql(true)
            0.upto(9) do
                @strategy.reviewStats.correct(item)
            end            
            # Now we know the items well enough, and we have reviewed
            # enough items, so we shouldn't review
            @strategy.shouldReview?.should eql(false)                        
        end

        it "should not review if all the items in the review set are seen" do
            @quiz.options.introThresh = 5
            # There are only review set items.  So we should review.
            @strategy.shouldReview?.should eql(true)

            # Set all the items in the review set to seen
            @quiz.contents.bins[Strategy.reviewSetBin].each do |item|
                item.firstSchedule.seen = true
            end
            @strategy.allSeen?(@quiz.contents.bins[Strategy.reviewSetBin]).should eql(true)

            # Even though we've seen all the items in the Review set,
            # there are only review set items, so we should still review
            @strategy.shouldReview?.should eql(true)

            item = test_addItem(Strategy.workingSetBin, -1)
            item.firstSchedule.seen = true
            # Now there is a working set item, and we don't have enough items
            # in the review set, so we should not review
            @strategy.shouldReview?.should eql(false)
            # Make a total of 4 items in the review set
            0.upto(3) do
                item = test_addItem(Strategy.reviewSetBin, -1)
                item.firstSchedule.seen = true
            end
            # We have enough items, and we haven't learned the review items
            # to the required level, so we would ordinarily review
            # However, all the review set items are seen, so we won't
            @strategy.shouldReview?.should eql(false)
        end
        
        it "should decrease the potential when an item is incorrect" do
            item = test_addItem(Strategy.reviewSetBin, -1)
	        @quiz.currentProblem = @strategy.createProblem(item)
	        item.firstSchedule.potential.should eql(432000)
	        @strategy.incorrect(item)
	        item.firstSchedule.potential.should eql(345600)
        end
        
        it "should decrease the potential 20% when demoted from the review set bin" do
            @quiz.options.promoteThresh = 1
            item = test_addItem(Strategy.workingSetBin, -1)
	        @quiz.currentProblem = @strategy.createProblem(item)
            pot1 = Schedule.defaultPotential
            item.firstSchedule.potential.should eql(pot1)
	        @strategy.incorrect(item)
            pot2 = pot1 - (0.2 * pot1).to_int
            item.firstSchedule.potential.should eql(pot2)
	        @strategy.incorrect(item)
            pot3 = pot2 - (0.2 * pot2).to_int
            item.firstSchedule.potential.should eql(pot3)
	        @strategy.incorrect(item)
            pot4 = pot3 - (0.2 * pot3).to_int
            item.firstSchedule.potential.should eql(pot4)
            item.bin.should eql(Strategy.workingSetBin)
	        @strategy.correct(item)
	        @strategy.correct(item)
	        @strategy.correct(item)
            item.bin.should eql(Strategy.reviewSetBin)
            pot5 = item.firstSchedule.duration
            # The potential is set to the duration of the schedule
            # when the item is promoted.
	        item.firstSchedule.potential.should eql(pot5)
	        @strategy.incorrect(item)
            item.bin.should eql(Strategy.workingSetBin)	        	        
            pot6 = pot5 - (0.2 * pot5).to_int
            item.firstSchedule.potential.should eql(pot6)
        end
        
        it "should reset the consecutive counter on an incorrect answer" do
            @quiz.options.promoteThresh = 1
            item = test_addItem(Strategy.workingSetBin, -1)
	        @quiz.currentProblem = @strategy.createProblem(item)
            item.bin.should eql(Strategy.workingSetBin)
	        @strategy.correct(item)
	        @strategy.correct(item)
	        @strategy.correct(item)
            item.bin.should eql(Strategy.reviewSetBin)
            # we only increase consecutive in the review set
            item.itemStats.consecutive.should eql(1)
	        @strategy.correct(item)
	        @strategy.correct(item)
	        @strategy.correct(item)
            item.itemStats.consecutive.should eql(4)

            @strategy.incorrect(item)
            item.bin.should eql(Strategy.workingSetBin)
            item.itemStats.consecutive.should eql(0)
        end
    end
end
