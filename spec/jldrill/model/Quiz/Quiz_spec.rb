require 'jldrill/model/Quiz/Quiz'

module JLDrill

	describe Quiz do
	
		before(:each) do
        	@fileString = %Q[0.2.0-LDRILL-SAVE Testfile
# This is the info line
Random Order
Promotion Threshold: 4
Introduction Threshold: 17
Strategy Version: 0
Unseen
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/
Poor
Fair
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 2/Level: 0/Position: 2/Consecutive: 0/
Good
Excellent
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 4/Level: 0/Position: 3/Consecutive: 1/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 4/Level: 0/Position: 4/Consecutive: 1/
]
		    @quiz = Quiz.new
		end

		it "should have the contents" do
		    @quiz.should_not be_nil
		    
		    @quiz.contents.should_not be_nil
		    @quiz.contents.bins.length.should be(5)
		    @quiz.contents.bins[0].name.should be_eql("Unseen")
		    @quiz.contents.bins[1].name.should be_eql("Poor")
		    @quiz.contents.bins[2].name.should be_eql("Fair")
		    @quiz.contents.bins[3].name.should be_eql("Good")
		    @quiz.contents.bins[4].name.should be_eql("Excellent")
		    @quiz.contents.to_s.should be_eql("Unseen\nPoor\nFair\nGood\nExcellent\n")
		end
		
		it "should have quiz options initialized" do
		    @quiz.options.should_not be_nil
		    @quiz.options.randomOrder.should be(false)
		    @quiz.options.promoteThresh.should be(2)
		    @quiz.options.introThresh.should be(10)
		    @quiz.options.oldThresh.should be(90)
		end
		
		def test_changeOption(optionString, originalValue, newValue)
		    @quiz.updated.should be(false)
		    eval("@quiz.options.#{optionString}").should be(originalValue)
		    eval("@quiz.options.#{optionString} = #{newValue}")
		    eval("@quiz.options.#{optionString}").should be(newValue)
		    @quiz.updated.should be(true)
		    @quiz.updated = false
		    @quiz.updated.should be(false)
		end
		
		it "should set the quiz to updated when the options are changed" do
		    test_changeOption("randomOrder", false, true)
		    test_changeOption("promoteThresh", 2, 4)
		    test_changeOption("introThresh", 10, 5)
		    test_changeOption("oldThresh", 90, 80)
		end
		
		it "should load a file from memory" do
		    @quiz.loadFromString("none", @fileString)
		    @quiz.loadFromString("none", @fileString).should be(true)
		    @quiz.savename.should be_eql("none")
		    @quiz.name.should be_eql("Testfile")
		    @quiz.options.randomOrder.should be(true)
		    @quiz.options.promoteThresh.should be(4)
		    @quiz.options.introThresh.should be(17)
		    @quiz.contents.bins[0].length.should be(1)
		    @quiz.contents.bins[1].length.should be(0)
		    @quiz.contents.bins[2].length.should be(1)
		    @quiz.contents.bins[3].length.should be(0)
		    @quiz.contents.bins[4].length.should be(2)
		end
		
		it "should save a file to a string" do
		    @quiz.loadFromString("none", @fileString)
		    @quiz.saveToString.should be_eql(@fileString)
		end
	
	    it "should be able to get a list of all the vocab" do
        	vocabString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 2/Level: 0/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 4/Level: 0/Position: 3/Consecutive: 1/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 4/Level: 0/Position: 4/Consecutive: 1/
]
	        @quiz.loadFromString("none", @fileString)
	        @quiz.allVocab.join.should be_eql(vocabString)
	    end
	    
	    it "should be able to reset the contents" do
	        # Note this vocabString is different from the previous test in that
	        # the bins are all set to 0
        	vocabString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/Consecutive: 0/
]
	        @quiz.loadFromString("none", @fileString)
	        @quiz.reset
	        @quiz.contents.bins[0].length.should be(4)
	        @quiz.contents.bins[1].length.should be(0)
	        @quiz.contents.bins[2].length.should be(0)
	        @quiz.contents.bins[3].length.should be(0)
	        @quiz.contents.bins[4].length.should be(0)
	        @quiz.contents.bins[0].contents.join.should be_eql(vocabString)
	    end
	    
	    it "should be able to move an item from one bin to the other" do
	        @quiz.loadFromString("none", @fileString)
	        vocab = @quiz.contents.bins[0][0]
	        @quiz.moveToBin(vocab, 4)
	        @quiz.contents.bins[0].length.should be(0)
	        @quiz.contents.bins[4].length.should be(3)
	        @quiz.contents.bins[4][2].to_s.should be_eql("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 4/Level: 0/Position: 1/Consecutive: 0/\n")
	        vocab.should be_equal(@quiz.contents.bins[4][2])
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
            test_problem(question, ReadingProblem.new(@quiz.vocab))
            @quiz.vocab.status.consecutive.should be(0)
	    end

        def test_level(question)
            case @quiz.currentProblem.requestedLevel
                when 0
                    test_problem(question, ReadingProblem.new(@quiz.vocab)) 
                when 1
                    test_problem(question, MeaningProblem.new(@quiz.vocab)) 
                when 2
                    if(!@quiz.vocab.kanji.nil?)
                        test_problem(question, KanjiProblem.new(@quiz.vocab))
                    else
                        test_problem(question, ReadingProblem.new(@quiz.vocab)) 
                    end
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
	    	@quiz.loadFromString("none", @fileString)
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
            test_problem(question, ReadingProblem.new(@quiz.vocab)) 
	        
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
            
            # Because we don't test level 4 items until we get 5 of them,
            # this should take exactly 20 iterations
            i = 0
            until (@quiz.contents.bins[4].length == 4) || (i > 20) do
                i += 1
                test_drill
                test_correct
            end
            i.should be(20)
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
	        @quiz.loadFromString("none", @fileString)
	        vocab = @quiz.contents.bins[4][0]
	        vocab.should_not be_nil
            @quiz.currentProblem = MeaningProblem.new(vocab)
            test_correct
            test_incorrect            
        end
    end
end