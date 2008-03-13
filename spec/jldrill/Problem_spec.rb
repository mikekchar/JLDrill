require 'jldrill/Problem'

module JLDrill

	describe Problem do
	
		before(:each) do
		    @vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem = Problem.new(@vocab)
        end
        
        it "should have a vocab associated with it" do
            @problem.should_not be_nil
            @problem.vocab.should be_equal(@vocab)
        end
        
        it "should give a string representation of the Kanji if it's there" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem1 = Problem.new(@vocab1)
            @problem1.should_not be_nil
            @problem1.kanji.should be_eql("会う\n")

		    @vocab2 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem2 = Problem.new(@vocab2)
            @problem2.should_not be_nil
            @problem2.kanji.should be_eql("")
        end

        it "should give a string representation of the Hint if it's there" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem1 = Problem.new(@vocab1)
            @problem1.should_not be_nil
            @problem1.hint.should be_eql("\nHint: No hints\n")

		    @vocab2 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem2 = Problem.new(@vocab2)
            @problem2.should_not be_nil
            @problem2.hint.should be_eql("")
        end

        it "should give a string representation of the Reading" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem1 = Problem.new(@vocab1)
            @problem1.should_not be_nil
            @problem1.reading.should be_eql("あう\n")
        end

        it "should give a string representation of the Definitions" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem1 = Problem.new(@vocab1)
            @problem1.should_not be_nil
            @problem1.definitions.should be_eql("to meet, to interview\n")
        end
        
    end

	describe ReadingProblem do
	
        it "should have a question of kanji, reading and hint and answer of definitions" do
		    @vocab = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem = ReadingProblem.new(@vocab)
            @problem.should_not be_nil
		    @problem.level.should be(0)
            @problem.question.should be_eql("会う\nあう\n\nHint: No hints\n")
            @problem.answer.should be_eql("to meet, to interview\n")
        end
    end

	describe KanjiProblem do
	
        it "should have a question of kanji and answer of reading, definitions and hint" do
		    @vocab = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem = KanjiProblem.new(@vocab)
            @problem.should_not be_nil
		    @problem.level.should be(2)
            @problem.question.should be_eql("会う\n")
            @problem.answer.should be_eql("あう\nto meet, to interview\n\nHint: No hints\n")
        end
    end

	describe MeaningProblem do
	
        it "should have a question of definitions and answer of kanji, readings and hint" do
		    @vocab = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem = MeaningProblem.new(@vocab)
            @problem.should_not be_nil
		    @problem.level.should be(1)
            @problem.question.should be_eql("to meet, to interview\n")
            @problem.answer.should be_eql("会う\nあう\n\nHint: No hints\n")
        end
    end


end
