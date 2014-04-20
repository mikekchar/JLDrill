# encoding: utf-8
require 'jldrill/model/Quiz'
require 'jldrill/spec/SampleQuiz'

module JLDrill

	describe Quiz do
	
		before(:each) do
		    @sampleQuiz = JLDrill::SampleQuiz.new
		    @quiz = @sampleQuiz.quiz
		    @emptyQuiz = @sampleQuiz.emptyQuiz
		end

		it "should have the contents" do
		    @emptyQuiz.should_not be_nil
		    
		    @emptyQuiz.contents.should_not be_nil
		    @emptyQuiz.contents.bins.length.should eql(4)
		    @emptyQuiz.contents.bins[0].name.should eql("New")
		    @emptyQuiz.contents.bins[1].name.should eql("Working")
		    @emptyQuiz.contents.bins[2].name.should eql("Review")
            @emptyQuiz.contents.bins[3].name.should eql("Forgotten")
		    @emptyQuiz.contents.to_s.should eql("New\nWorking\nReview\nForgotten\n")
		end
		
		it "should load a file from memory" do
		    quiz = Quiz.new
		    quiz.loadFromString("SampleQuiz", @sampleQuiz.file)
		    quiz.file.should eql("SampleQuiz")
		    quiz.name.should eql("Testfile")
		    quiz.options.randomOrder.should eql(true)
		    quiz.options.promoteThresh.should eql(4)
		    quiz.options.introThresh.should eql(17)
		    quiz.contents.newSet.length.should eql(1)
		    quiz.contents.workingSet.length.should eql(1)
		    quiz.contents.reviewSet.length.should eql(2)
		    quiz.contents.forgottenSet.length.should eql(0)
		end
		
		it "should save a file to a string" do
		    @quiz.saveToString.should eql(@sampleQuiz.file)
		end

        it "should be able to load files of the current version" do
            Quiz.canLoad?(SampleQuiz::FileHeader).should eql(true)
            @emptyQuiz.loadFromString("TestFile", @sampleQuiz.file)
            @emptyQuiz.saveToString.should eql(@sampleQuiz.file)
        end
	
        # Defined this since it's useful in the tests, but I
        # removed it from Quiz (I don't want to use it)
        def allVocabString(quiz)
	        items = @quiz.allItems
            string = ""
            items.each do |item|
                string += item.to_o.to_s + "\n"
            end
            return string
        end

	    it "should be able to get a list of all the items" do
            string = allVocabString(@quiz)
            string.should eql(@sampleQuiz.allVocab + "\n")
	    end
	    
	    it "should be able to reset the contents" do
	        @quiz.resetContents
	        @quiz.contents.newSet.length.should eql(3)
	        @quiz.contents.workingSet.length.should eql(1)
	        @quiz.contents.reviewSet.length.should eql(0)
	        @quiz.contents.forgottenSet.length.should eql(0)
            string = allVocabString(@quiz)
	        string.should eql(@sampleQuiz.allResetVocab + "\n")
	    end

        it "should renumber the contents when resetting" do
            @quiz.resetContents
            @quiz.contents.newSet[0].state.reposition(5)
            @quiz.contents.newSet[1].state.reposition(6)
            @quiz.contents.newSet[2].state.reposition(6)
            @quiz.contents.workingSet[0].state.reposition(7)
            @quiz.options.randomOrder = false
            @quiz.resetContents
            # The first item will be drilled and therefore promoted to bin 1
            @quiz.contents.bins[1][0].state.position.should be(0)
            # The rest will be in bin 0, numbered sequentially
            0.upto(2) do |i|
                @quiz.contents.bins[0][i].state.position.should eql(i + 1)
            end
        end
	    
	    it "should be able to move an item from one bin to the other" do
	        item = @quiz.contents.newSet[0]
	        @quiz.contents.moveToReviewSet(item)
	        @quiz.contents.newSet.length.should eql(0)
	        @quiz.contents.reviewSet.length.should eql(3)
	        item.should be_equal(@quiz.contents.reviewSet[2])
	        item.state.should be_inReviewSet
	    end
	    
        def test_problem(question, problem)
	        question.should eql(problem.question)
	        
	        @quiz.currentDrill.should eql(problem.question)
	        @quiz.currentAnswer.should eql(problem.answer)
	        @quiz.answer.should eql(problem.answer)
        end

        def test_level(question)
            item = @quiz.currentProblem.item
            schedule = item.state.currentSchedule
            case @quiz.currentProblem.requestedLevel
                when 0
                    test_problem(question, 
                                 ReadingProblem.new(item)) 
                when 1
                    if(!@quiz.currentProblem.item.to_o.kanji.nil?)
                        test_problem(question, 
                                     KanjiProblem.new(item))
                    else
                        test_problem(question, 
                                     ReadingProblem.new(item)) 
                    end
                when 2
                    test_problem(question, MeaningProblem.new(item)) 
            else
	             # This shouldn't ever happen.  Blow up.
	             true.should eql(false) 
            end                
        end
       
	    def test_workingSet(question)
            # The quiz depends on the level
            test_level(question)
            @quiz.currentProblem.item.state.itemStats.consecutive.should eql(0)
	    end

	    def test_reviewSet(question)
            # The quiz depends on the level
            test_level(question)
            # Level 4 items have consecutive of at least one
            @quiz.currentProblem.item.state.itemStats.consecutive.should_not eql(0)
	    end
	    
	    def test_drill
	        newSetSize = @quiz.contents.newSet.length
	        @quiz.drill
            question = @quiz.currentDrill
	        if (newSetSize - 1) == @quiz.contents.newSet.length
	            # it was a bin 0 item which was promoted
	            @quiz.currentProblem.item.state.should be_inWorkingSet
                test_workingSet(question)
	        elsif @quiz.currentProblem.item.state.inWorkingSet?
	            test_workingSet(question)
	        elsif @quiz.currentProblem.item.state.inReviewSet?
	            test_reviewSet(question)
	        else
	             # This shouldn't ever happen.  Blow up.
	             true.should eql(false) 
	        end 
	    end

        def test_correct
            consecutive = @quiz.currentProblem.item.state.itemStats.consecutive
            @quiz.correct
            if @quiz.currentProblem.item.state.inReviewSet?
                @quiz.currentProblem.item.state.itemStats.consecutive.should eql(consecutive + 1)
            else
                @quiz.currentProblem.item.state.itemStats.consecutive.should eql(0)
            end
        end
	    
        def test_incorrect
            @quiz.incorrect
            @quiz.currentProblem.item.state.itemStats.consecutive.should eql(0)
        end
	    
	    def test_initializeQuiz
	    	@quiz.loadFromString("none", @sampleQuiz.file)
	    	@quiz.options.randomOrder = false
	    	@quiz.options.promoteThresh = 1
            # Reset now does a drill()
	        @quiz.resetContents
	    end
	    
	    it "should be able to create a new Problem" do
            # The reset in test_initializeQuiz now does a drill()
	        test_initializeQuiz
	        # Non random should pick the first object in the first bin
	        # item gets promoted to the first bin immediately
	        item = @quiz.contents.workingSet[0]
	        @quiz.contents.newSet.length.should eql(3)
	        @quiz.contents.workingSet.length.should eql(1)
            test_problem(@quiz.currentProblem.question, 
                         ReadingProblem.new(@quiz.currentProblem.item)) 
	        @quiz.currentProblem.item.should be_equal(item)

            # Threshold is 1, so a correct answer should promote
            test_correct
        end
        
        it "should eventually promote all items to review set" do
            test_initializeQuiz
            
            # Because we don't test review set items until we get one working set 
            # of them, this should take exactly 12 iterations
            # However test_initializeQuiz now does a drill() so in the
            # first iteration we just need to do test_correct.
            test_correct
            i = 1
            until (@quiz.contents.reviewSet.length == 4) || (i > 12) do
                i += 1
                test_drill
                test_correct
            end
            i.should eql(12)
        end

        it "should use the promote threshold when promoting" do
            test_initializeQuiz
            @quiz.options.promoteThresh = 2
            
            # Because we don't test level 4 items until we get one working set 
            # of them, this should take exactly 24 iterations
            # However test_initializeQuiz now does a drill() so in the
            # first iteration we just need to do test_correct.
            test_correct
            i = 1
            until (@quiz.contents.reviewSet.length == 4) || (i > 24) do
                i += 1
                test_drill
                test_correct
            end
            i.should eql(24)
        end
        
        it "should update the last reviewed status when the answer is made" do
            test_initializeQuiz
            @quiz.currentProblem.item.state.currentSchedule.lastReviewed.should be_nil
            schedule1 = @quiz.currentProblem.item.state.currentSchedule
            test_correct
            test1 = @quiz.currentProblem.item
            schedule1.lastReviewed.should_not be_nil

            # should get a new one
            test_drill
            test2 = @quiz.currentProblem.item
            schedule2 = test2.state.currentSchedule
            schedule2.lastReviewed.should be_nil

            # Make it incorrect
            test_incorrect

            schedule2.lastReviewed.should_not be_nil

            # After a reset, test1 is the first item so it will be
            # moved to the working set.  As such it will have a schedule.
            # The lastReviewed should be set to nil.
            # test2, on the other hand, is in the new set so it shouldn't
            # have a schedule at all.
            @quiz.resetContents
            test1.state.currentSchedule.lastReviewed.should be_nil
            test2.state.currentSchedule.should be_nil
        end
        
        it "should update the schedule correctly for review set items" do
	        @quiz.loadFromString("none", @sampleQuiz.file)
	        item = @quiz.contents.reviewSet[0]
	        item.should_not be_nil
            schedule = item.state.currentSchedule
            @quiz.currentProblem = MeaningProblem.new(item)
            test_correct
            test_incorrect            
        end

        it "should notify subscribers of updates" do
            subscriber = double("Subscriber")
            @quiz.subscribe(subscriber)
            subscriber.should_receive(:quizUpdated)
            @quiz.update
        end
        
        it "should notify subscribers when a new problem has been created" do
            subscriber = double("Subscriber")
            @quiz.publisher.subscribe(subscriber, "newProblem")
            subscriber.should_receive(:newProblemUpdated)
            test_initializeQuiz
            # Note: the reset() in test_initializeQuiz does a drill() now
        end

        it "should be able to find paths relative to the save name" do
            @quiz.file = "/usr/share/fake.jldrill"
            root = File.expand_path("/")
            @quiz.useSavePath("mydirectory/newfile").should eql(root + "usr/share/mydirectory/newfile")
            @quiz.useSavePath("../../newfile").should eql(root + "newfile")
        end
    end
end
