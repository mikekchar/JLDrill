require 'jldrill/model/Problem'

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
        
        it "should have and empty string if the reading isn't set" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem1 = Problem.new(@vocab1)
            @problem1.should_not be_nil
            @problem1.reading.should be_eql("")
        end

        it "should have and empty string if the definitions aren't set" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
		    @problem1 = Problem.new(@vocab1)
            @problem1.should_not be_nil
            @problem1.definitions.should be_eql("")
        end
        
        it "should be able to assign a vocab" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
            @problem1 = Problem.new(@vocab1)
		    @vocab2 = Vocabulary.create("/Kanji: 雨/Reading: あめ/Definitions: rain/Markers: n,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
            @problem1.vocab = @vocab2
            @problem1.vocab.should be_eql(@vocab2)
        end

        it "should create a ReadingProblem for level 0" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 1/Level: 0/Position: 1/")
            problem1 = Problem.create(0, vocab1)
            problem1.should be_a_kind_of(ReadingProblem)
        end        

        it "should create a KanjiProblem for level 1" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 2/Level: 1/Position: 1/")
            problem1 = Problem.create(1, vocab1)
            problem1.should be_a_kind_of(KanjiProblem)
        end        

        it "should create a MeaningProblem for level 2" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 3/Level: 2/Position: 1/")
            problem1 = Problem.create(2, vocab1)
            problem1.should be_a_kind_of(MeaningProblem)
        end        

        it "should create a MeaningProblem for level 1 if there is no kanji" do
            vocab1 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 4/Level: 2/Position: 1/")
            problem1 = Problem.create(1, vocab1)
            problem1.should be_a_kind_of(MeaningProblem)
        end        

        it "should create a ReadingProblem for unknown levels" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
            problem1 = Problem.create(-1, vocab1)
            problem1.should be_a_kind_of(ReadingProblem)
        end        
        
        it "should print the status correctly" do
            problem1 = Problem.create(0, Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 1/Level: 0/Position: 1/"))
            problem2 = Problem.create(0, Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 2/Level: 0/Position: 1/"))
            problem3 = Problem.create(0, Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 3/Level: 0/Position: 1/"))
            problem4 = Problem.create(0, Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 4/Level: 0/Position: 1/"))
            problem1.status.should be_eql("Current: 1")
            problem2.status.should be_eql("Current: 2")
            problem3.status.should be_eql("Current: 3")
            problem4.status.should be_eql("Current: 4")
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
