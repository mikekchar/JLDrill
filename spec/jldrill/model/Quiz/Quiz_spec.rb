require 'jldrill/model/Quiz/Quiz'
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
		    @emptyQuiz.contents.bins.length.should be(5)
		    @emptyQuiz.contents.bins[0].name.should be_eql("Unseen")
		    @emptyQuiz.contents.bins[1].name.should be_eql("Poor")
		    @emptyQuiz.contents.bins[2].name.should be_eql("Fair")
		    @emptyQuiz.contents.bins[3].name.should be_eql("Good")
		    @emptyQuiz.contents.bins[4].name.should be_eql("Excellent")
		    @emptyQuiz.contents.to_s.should be_eql("Unseen\nPoor\nFair\nGood\nExcellent\n")
		end
		
		it "should have quiz options initialized" do
		    @emptyQuiz.options.should_not be_nil
		    @emptyQuiz.options.randomOrder.should be(false)
		    @emptyQuiz.options.promoteThresh.should be(2)
		    @emptyQuiz.options.introThresh.should be(10)
		    @emptyQuiz.options.oldThresh.should be(90)
		end
		
		def test_changeOption(optionString, originalValue, newValue)
		    @emptyQuiz.needsSave.should be(false)
		    eval("@emptyQuiz.options.#{optionString}").should be(originalValue)
		    eval("@emptyQuiz.options.#{optionString} = #{newValue}")
		    eval("@emptyQuiz.options.#{optionString}").should be(newValue)
		    @emptyQuiz.needsSave.should be(true)
		    @emptyQuiz.setNeedsSave(false)
		    @emptyQuiz.needsSave.should be(false)
		end
		
		it "should set the quiz to needsSave when the options are changed" do
		    test_changeOption("randomOrder", false, true)
		    test_changeOption("promoteThresh", 2, 4)
		    test_changeOption("introThresh", 10, 5)
		    test_changeOption("oldThresh", 90, 80)
		end
		
		it "should load a file from memory" do
		    quiz = Quiz.new
		    quiz.loadFromString("SampleQuiz", @sampleQuiz.file)
		    quiz.savename.should be_eql("SampleQuiz")
		    quiz.name.should be_eql("Testfile")
		    quiz.options.randomOrder.should be(true)
		    quiz.options.promoteThresh.should be(4)
		    quiz.options.introThresh.should be(17)
		    quiz.contents.bins[0].length.should be(1)
		    quiz.contents.bins[1].length.should be(0)
		    quiz.contents.bins[2].length.should be(1)
		    quiz.contents.bins[3].length.should be(0)
		    quiz.contents.bins[4].length.should be(2)
		end
		
		it "should save a file to a string" do
		    @quiz.saveToString.should be_eql(@sampleQuiz.file)
		end

        it "should be able to load files of the current version" do
            Quiz.canLoad?(SampleQuiz::FileHeader).should be(true)
            @emptyQuiz.loadFromString("TestFile", @sampleQuiz.file)
            @emptyQuiz.saveToString.should be_eql(@sampleQuiz.file)
        end
	
	    it "should be able to get a list of all the vocab" do
	        @quiz.allVocab.join.should be_eql(@sampleQuiz.allVocab)
	    end
	    
	    it "should be able to reset the contents" do
	        @quiz.reset
	        @quiz.contents.bins[0].length.should be(4)
	        @quiz.contents.bins[1].length.should be(0)
	        @quiz.contents.bins[2].length.should be(0)
	        @quiz.contents.bins[3].length.should be(0)
	        @quiz.contents.bins[4].length.should be(0)
	        @quiz.contents.bins[0].contents.join.should eql(@sampleQuiz.allResetVocab)
	    end
	    
	    it "should be able to move an item from one bin to the other" do
	        vocab = @quiz.contents.bins[0][0]
	        @quiz.strategy.moveToBin(vocab, 4)
	        @quiz.contents.bins[0].length.should be(0)
	        @quiz.contents.bins[4].length.should be(3)
	        vocab.should be_equal(@quiz.contents.bins[4][2])
	        vocab.status.bin.should be(4)
	    end
	    
        def test_problem(question, problem)
	        question.should be_eql(problem.question)
	        
	        @quiz.currentDrill.should be_eql(problem.question)
	        @quiz.currentAnswer.should be_eql(problem.answer)
	        @quiz.answer.should be_eql(problem.answer)
        end

	    def test_binOne(question)
            # bin 1 items will always be reading problems
            # because the level will always be 0
            @quiz.vocab.status.level.should be(0)
            test_problem(question, ReadingProblem.new(@quiz.vocab, @quiz))
            @quiz.vocab.status.consecutive.should be(0)
	    end

        def test_level(question)
            case @quiz.currentProblem.requestedLevel
                when 0
                    test_problem(question, ReadingProblem.new(@quiz.vocab, @quiz)) 
                when 1
                    if(!@quiz.vocab.kanji.nil?)
                        test_problem(question, KanjiProblem.new(@quiz.vocab, @quiz))
                    else
                        test_problem(question, ReadingProblem.new(@quiz.vocab, @quiz)) 
                    end
                when 2
                    test_problem(question, MeaningProblem.new(@quiz.vocab, @quiz)) 
            else
	             # This shouldn't ever happen.  Blow up.
	             true.should be(false) 
            end                
        end
        
	    def test_binTwo(question)
            # The quiz depends on the level
            test_level(question)
            @quiz.vocab.status.consecutive.should be(0)
	    end

	    def test_binThree(question)
            # The quiz depends on the level
            test_level(question)
            @quiz.vocab.status.consecutive.should be(0)
	    end

	    def test_binFour(question)
	        # Since it's random, this might not always be hit.  But
	        # if this test fails, it's definitely a bug!
	        @quiz.currentProblem.requestedLevel.should_not be(0)
	        
            # The quiz depends on the level
            test_level(question)
            # Level 4 items have consecutive of at least one
            @quiz.vocab.status.consecutive.should_not be(0)
	    end
	    
	    def test_drill
	        binZeroSize = @quiz.contents.bins[0].length
	        question = @quiz.drill
	        if (binZeroSize - 1) == @quiz.contents.bins[0].length
	            # it was a bin 0 item which was promoted
	            @quiz.vocab.status.bin.should be(1)
                test_binOne(question)
	        elsif @quiz.vocab.status.bin == 1
	            test_binOne(question)
	        elsif @quiz.vocab.status.bin == 2
	            test_binTwo(question)
	        elsif @quiz.vocab.status.bin == 3
	            test_binThree(question)
	        elsif @quiz.vocab.status.bin == 4
	            test_binFour(question)
	        else
	             # This shouldn't ever happen.  Blow up.
	             true.should be(false) 
	        end 
	    end

        def test_correct
            consecutive = @quiz.vocab.status.consecutive
            @quiz.correct
            bin = @quiz.vocab.status.bin
            if bin == 4
                @quiz.vocab.status.consecutive.should be_eql(consecutive + 1)
            else
                @quiz.vocab.status.consecutive.should be(0)
            end
        end
	    
        def test_incorrect
            @quiz.incorrect
            @quiz.vocab.status.consecutive.should be(0)
        end
	    
	    def test_initializeQuiz
	    	@quiz.loadFromString("none", @sampleQuiz.file)
	    	@quiz.options.randomOrder = false
	    	@quiz.options.promoteThresh = 1
	        @quiz.reset	    
	    end
	    
	    it "should be able to create a new Problem" do
	        test_initializeQuiz
	        # Non random should pick the first object in the first bin
	        vocab = @quiz.contents.bins[0][0]
	        @quiz.contents.bins[0].length.should be(4)
	        @quiz.contents.bins[1].length.should be(0)
	        question = @quiz.drill
            test_problem(question, ReadingProblem.new(@quiz.vocab, @quiz)) 
	        
	        # item gets promoted to the first bin immediately
	        @quiz.contents.bins[0].length.should be(3)
	        @quiz.contents.bins[1].length.should be(1)
	        @quiz.bin.should be(1)
	        @quiz.vocab.should be_equal(vocab)

            # Threshold is 1, so a correct answer should promote
            test_correct
        end
        
        it "should eventually promote all items to bin 4" do
            test_initializeQuiz
            
            # Because we don't test level 4 items until we get one working set 
            # of them, this should take exactly 12 iterations
            i = 0
            until (@quiz.contents.bins[4].length == 4) || (i > 12) do
                i += 1
                test_drill
                test_correct
            end
            i.should be(12)
        end

        it "should use the promote threshold when promoting" do
            test_initializeQuiz
            @quiz.options.promoteThresh = 2
            
            # Because we don't test level 4 items until we get one working set 
            # of them, this should take exactly 24 iterations
            i = 0
            until (@quiz.contents.bins[4].length == 4) || (i > 24) do
                i += 1
                test_drill
                test_correct
            end
            i.should be(24)
        end
        
        it "should update the last reviewed status when the answer is made" do
            test_initializeQuiz
            test_drill
            @quiz.vocab.status.lastReviewed.should be_nil
            test_correct
            test1 = @quiz.vocab
            test1.status.lastReviewed.should_not be_nil
            # should get a new one
            test_drill
            test2 = @quiz.vocab
            test2.status.lastReviewed.should be_nil
            test_incorrect
            @quiz.vocab.status.lastReviewed.should_not be_nil
            @quiz.reset
            test1.status.lastReviewed.should be_nil
            test2.status.lastReviewed.should be_nil
        end
        
        it "should update the status correctly for bin 4 items" do
	        @quiz.loadFromString("none", @sampleQuiz.file)
	        vocab = @quiz.contents.bins[4][0]
	        vocab.should_not be_nil
            @quiz.currentProblem = MeaningProblem.new(vocab, @quiz)
            test_correct
            test_incorrect            
        end

        it "should notify subscribers of updates" do
            subscriber = mock("Subscriber")
            @quiz.subscribe(subscriber)
            subscriber.should_receive(:quizUpdated)
            @quiz.update
        end
        
        it "should notify subscribers when a new problem has been created" do
            test_initializeQuiz
            subscriber = mock("Subscriber")
            @quiz.publisher.subscribe(subscriber, "newProblem")
            subscriber.should_receive(:newProblemUpdated)
            @quiz.drill
        end
    end
end
