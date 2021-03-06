# encoding: utf-8
require 'jldrill/model/quiz/Contents'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/Problem'
require 'jldrill/model/problems/ProblemFactory'
require 'jldrill/spec/SampleQuiz'

module JLDrill

	describe "Selection Strategy" do
	
	    before(:each) do
	        @quiz = Quiz.new
	        @sampleQuiz = SampleQuiz.new
	        vocab = @sampleQuiz.sampleVocab
	        item = @quiz.contents.add(vocab, @quiz.contents.reviewSetBin)
	        @quiz.currentProblem = ReadingProblem.new(item)
	    end
	    
        # Adds a sample vocabulary to a bin in a position and returns the item
        def test_addItem(bin, position)
            item = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
            item.state.reposition(position)
            @quiz.contents.addItem(item, bin)
            return item
        end
	    
	    it "should demote new set items to new set" do
	        # Demoting new set items is non-sensical, but it should do
	        # something sensible anyway.
	        item = test_addItem(@quiz.contents.newSetBin, 1)
	        @quiz.contents.newSet.demote(item)
	        item.state.should be_inNewSet
	        item.state.currentSchedule.should be_nil
	    end

	    it "should demote other items to the working set" do
	        item = test_addItem(@quiz.contents.workingSetBin, 1)
	        @quiz.contents.workingSet.demote(item)
	        item.state.should be_inWorkingSet

	        item = test_addItem(@quiz.contents.reviewSetBin, 2)
	        @quiz.contents.reviewSet.demote(item)
	        item.state.should be_inWorkingSet

	        item = test_addItem(@quiz.contents.forgottenSetBin, 3)
	        @quiz.contents.forgottenSet.demote(item)
	        item.state.should be_inWorkingSet
	    end
	    
	    it "should be able to create problems of the correct level" do
            @quiz.options.promoteThresh = 1

	        item1 = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
	        item1.state.moveTo(@quiz.contents.workingSetBin)
            problemStatus = item1.state.problemStatus
            problemStatus.checkSchedules
            problemStatus.findScheduleForLevel(0).should_not eql(nil)
            item1.state.currentSchedule.problemType.should eql("ReadingProblem")

	        item2 = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
	        item2.state.moveTo(@quiz.contents.workingSetBin)
            problemStatus = item2.state.problemStatus
            problemStatus.checkSchedules
            problemStatus.findScheduleForLevel(1).should_not eql(nil)
            item2.state.correct()
            item2.state.currentSchedule.problemType.should eql("KanjiProblem")
	        
	        item3 = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
	        item3.state.moveTo(@quiz.contents.workingSetBin)
            problemStatus = item3.state.problemStatus
            problemStatus.checkSchedules
            problemStatus.findScheduleForLevel(2).should_not eql(nil)
            item3.state.correct()
            item3.state.correct()
            item3.state.currentSchedule.problemType.should eql("MeaningProblem")
            
            problem1 = item1.state.createProblem
            problem2 = item2.state.createProblem
            problem3 = item3.state.createProblem
            problem1.should be_a_kind_of(ReadingProblem)
            problem2.should be_a_kind_of(KanjiProblem)
            problem3.should be_a_kind_of(MeaningProblem)
	    end
    
        it "should be able to tell if the working set is full" do
            @quiz.options.introThresh = 5
            @quiz.contents.workingSet.full?.should eql(false)
	        test_addItem(@quiz.contents.workingSetBin, -1)
            @quiz.contents.workingSet.full?.should eql(false)
	        test_addItem(@quiz.contents.workingSetBin, -1)
            @quiz.contents.workingSet.full?.should eql(false)
	        test_addItem(@quiz.contents.workingSetBin, -1)
            @quiz.contents.workingSet.full?.should eql(false)
	        test_addItem(@quiz.contents.workingSetBin, -1)
            @quiz.contents.workingSet.full?.should eql(false)
            0.upto(10) do
                test_addItem(@quiz.contents.newSetBin, -1)
                test_addItem(@quiz.contents.reviewSetBin, -1)
    	    end
            @quiz.contents.workingSet.full?.should eql(false)
            test_addItem(@quiz.contents.workingSetBin, -1)
            @quiz.contents.workingSet.full?.should eql(true)
        end
        
        it "should be able to tell if the review set needs reviewing" do
            @quiz.options.introThresh = 5
            # There are only review set items.  So we should review.
            @quiz.contents.shouldReview?.should eql(true)
            
            item = test_addItem(@quiz.contents.workingSetBin, -1)
            # Now there is a working set item, and we don't have enough items
            # in the review set, so we should not review
            @quiz.contents.shouldReview?.should eql(false)
            # Make a total of 4 items in the review set
            0.upto(3) do
                item = test_addItem(@quiz.contents.reviewSetBin, -1)
            end
            # We have enough items, and we haven't learned the review items
            # to the required level, so we should review
            @quiz.contents.shouldReview?.should eql(true)
            0.upto(9) do
                @quiz.contents.reviewSet.stats.correct(item)
            end
            # We don't start the countdown until we have reviewed 10 items
            # so we should continue to review
            @quiz.contents.shouldReview?.should eql(true)
            0.upto(9) do
                @quiz.contents.reviewSet.stats.correct(item)
            end            
            # Now we know the items well enough, and we have reviewed
            # enough items, so we shouldn't review
            @quiz.contents.shouldReview?.should eql(false)                        
        end

        it "should not review if all the items in the review set are seen" do
            @quiz.options.introThresh = 5
            # There are only review set items.  So we should review.
            @quiz.contents.shouldReview?.should eql(true)

            # Set all the items in the review set to seen
            @quiz.contents.reviewSet.each do |item|
                item.state.currentSchedule.seen = true
            end
            @quiz.contents.reviewSet.should be_allSeen

            # Even though we've seen all the items in the Review set,
            # there are only review set items, so we should still review
            @quiz.contents.shouldReview?.should eql(true)

            item = test_addItem(@quiz.contents.workingSetBin, -1)
            item.state.currentSchedule.seen = true
            # Now there is a working set item, and we don't have enough items
            # in the review set, so we should not review
            @quiz.contents.shouldReview?.should eql(false)
            # Make a total of 4 items in the review set
            0.upto(3) do
                item = test_addItem(@quiz.contents.reviewSetBin, -1)
                item.state.currentSchedule.seen = true
            end
            # We have enough items, and we haven't learned the review items
            # to the required level, so we would ordinarily review
            # However, all the review set items are seen, so we won't
            @quiz.contents.shouldReview?.should eql(false)
        end
        
        it "should decrease the potential when an item is incorrect" do
            item = test_addItem(@quiz.contents.reviewSetBin, -1)
	        @quiz.currentProblem = item.state.createProblem()
	        item.state.currentSchedule.potential.should eql(432000)
	        item.state.incorrect()
	        item.state.currentSchedule.potential.should eql(345600)
        end
        
        it "should decrease the potential 20% when demoted from the review set bin" do
            @quiz.options.promoteThresh = 1
            item = test_addItem(@quiz.contents.workingSetBin, -1)
	        @quiz.currentProblem = item.state.createProblem()
            pot1 = Schedule.defaultPotential
            item.state.currentSchedule.potential.should eql(pot1)
	        item.state.incorrect()
            pot2 = pot1 - (0.2 * pot1).to_int
            item.state.currentSchedule.potential.should eql(pot2)
	        item.state.incorrect()
            pot3 = pot2 - (0.2 * pot2).to_int
            item.state.currentSchedule.potential.should eql(pot3)
	        item.state.incorrect()
            pot4 = pot3 - (0.2 * pot3).to_int
            item.state.currentSchedule.potential.should eql(pot4)
            item.state.should be_inWorkingSet
	        item.state.correct()
	        item.state.correct()
	        item.state.correct()
            item.state.should be_inReviewSet
            pot5 = item.state.currentSchedule.duration
            # The potential is set to the duration of the schedule
            # when the item is promoted.
	        item.state.currentSchedule.potential.should eql(pot5)
	        item.state.incorrect()
            item.state.should be_inWorkingSet
            pot6 = pot5 - (0.2 * pot5).to_int
            item.state.currentSchedule.potential.should eql(pot6)
        end
        
        it "should reset the consecutive counter on an incorrect answer" do
            @quiz.options.promoteThresh = 1
            item = test_addItem(@quiz.contents.workingSetBin, -1)
	        @quiz.currentProblem = item.state.createProblem()
            item.state.should be_inWorkingSet
	        item.state.correct()
	        item.state.correct()
	        item.state.correct()
            item.state.should be_inReviewSet
            # we only increase consecutive in the review set
            item.state.itemStats.consecutive.should eql(1)
	        item.state.correct()
	        item.state.correct()
	        item.state.correct()
            item.state.itemStats.consecutive.should eql(4)

            item.state.incorrect()
            item.state.should be_inWorkingSet
            item.state.itemStats.consecutive.should eql(0)
        end
    end
end
