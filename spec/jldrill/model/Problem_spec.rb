require 'jldrill/model/Problem'

module JLDrill

	describe Problem do
	
		before(:each) do
		    @quiz = Quiz.new
		    @vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item = @quiz.contents.add(@vocab, 0)
		    @problem = Problem.new(@item, @quiz)
        end
        
        it "should have a vocab associated with it" do
            @problem.should_not be_nil
            @item.should_not be nil
            @item.should be_contain(@vocab)
            @item.should equal(@problem.item)
        end
        
        it "should give a string representation of the Kanji if it's there" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: /Score: 0/Level: 01/")
		    @item1 = Item.new(@vocab1)
		    @problem1 = Problem.new(@item1, @quiz)
            @problem1.should_not be_nil
            @problem1.kanji.should eql("会う")

		    @vocab2 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item2 = Item.new(@vocab2)
		    @problem2 = Problem.new(@item2, @quiz)
            @problem2.should_not be_nil
            @problem2.kanji.should eql("")
        end

        it "should give a string representation of the Hint if it's there" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item1 = Item.new(@vocab1)
		    @problem1 = Problem.new(@item1, @quiz)
            @problem1.should_not be_nil
            @problem1.hint.should eql("Hint: No hints")

		    @vocab2 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item2 = Item.new(@vocab2)
		    @problem2 = Problem.new(@item2, @quiz)
            @problem2.should_not be_nil
            @problem2.hint.should eql("")
        end

        it "should give a string representation of the Reading" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item1 = Item.new(@vocab1)
		    @problem1 = Problem.new(@item1, @quiz)
            @problem1.should_not be_nil
            @problem1.reading.should eql("あう")
        end

        it "should give a string representation of the Definitions" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item1 = Item.new(@vocab1)
		    @problem1 = Problem.new(@item1, @quiz)
            @problem1.should_not be_nil
            @problem1.definitions.should eql("to meet, to interview")
        end
        
        it "should have and empty string if the reading isn't set" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item1 = Item.new(@vocab1)
		    @problem1 = Problem.new(@item1, @quiz)
            @problem1.should_not be_nil
            @problem1.reading.should eql("")
        end

        it "should have and empty string if the definitions aren't set" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Hint: No hints/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item1 = Item.new(@vocab1)
		    @problem1 = Problem.new(@item1, @quiz)
            @problem1.should_not be_nil
            @problem1.definitions.should eql("")
        end
        
        it "should be able to assign a vocab" do
		    @vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item1 = Item.new(@vocab1)
		    @problem1 = Problem.new(@item1, @quiz)
		    @vocab2 = Vocabulary.create("/Kanji: 雨/Reading: あめ/Definitions: rain/Markers: n,P/Position: 1/Score: 0/Level: 0/")
            @problem1.vocab = @vocab2
            @problem1.item.to_o.should eql(@vocab2)
        end

        it "should create a ReadingProblem for level 0" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    item1 = Item.new(vocab1)
            problem1 = Problem.create(0, item1, @quiz)
            problem1.should be_a_kind_of(ReadingProblem)
        end        

        it "should create a KanjiProblem for level 1" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 1/")
		    item1 = Item.new(vocab1)
            problem1 = Problem.create(1, item1, @quiz)
            problem1.should be_a_kind_of(KanjiProblem)
        end        

        it "should create a MeaningProblem for level 2" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 2/")
		    item1 = Item.new(vocab1)
            problem1 = Problem.create(2, item1, @quiz)
            problem1.should be_a_kind_of(MeaningProblem)
        end        

        it "should create a MeaningProblem for level 1 if there is no kanji" do
            vocab1 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 2/")
		    item1 = Item.new(vocab1)
            problem1 = Problem.create(1, item1, @quiz)
            problem1.should be_a_kind_of(MeaningProblem)
        end        

        it "should create a ReadingProblem for unknown levels" do
            vocab1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    item1 = Item.new(vocab1)
            problem1 = Problem.create(-1, item1, @quiz)
            problem1.should be_a_kind_of(ReadingProblem)
        end        
        
        def createFakeItem(bin)
            item = Item.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 0/Score: 0/Level: 0/")
            item.bin = bin
            return item
        end

        it "should print the status correctly" do
            i1 = createFakeItem(1)
            i2 = createFakeItem(2)
            i3 = createFakeItem(3)
            i4 = createFakeItem(4)
            
            problem1 = Problem.create(0, i1, @quiz)
            problem2 = Problem.create(0, i2, @quiz)
            problem3 = Problem.create(0, i3, @quiz)
            problem4 = Problem.create(0, i4, @quiz)

            problem1.status.should eql("     1 --> 5.0 days")
            problem2.status.should eql("     2 --> 5.0 days")
            problem3.status.should eql("     3 --> 5.0 days")
            problem4.status.should eql("     +0 --> 5.0 days")
            problem4.item.schedule.markReviewed
            problem4.status.should eql("     +0, Today --> 5.0 days")
        end
    end

	describe ReadingProblem do
	
        it "should have a question of kanji, reading and hint and answer of definitions" do
		    @vocab = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item = Item.new(@vocab)
		    @problem = ReadingProblem.new(@item, @quiz)
            @problem.should_not be_nil
		    @problem.level.should be(0)
            @problem.question.should eql("会う\nあう\nHint: No hints\n")
            @problem.answer.should eql("to meet, to interview\n")
        end
    end

	describe KanjiProblem do
	
        it "should have a question of kanji and answer of reading, definitions and hint" do
		    @vocab = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item = Item.new(@vocab)
		    @problem = KanjiProblem.new(@item, @quiz)
            @problem.should_not be_nil
		    @problem.level.should be(2)
            @problem.question.should eql("会う\n")
            @problem.answer.should eql("あう\nto meet, to interview\nHint: No hints\n")
        end
    end

	describe MeaningProblem do
	
        it "should have a question of definitions and answer of kanji, readings and hint" do
		    @vocab = Vocabulary.create("/Kanji: 会う/Hint: No hints/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/")
		    @item = Item.new(@vocab)
		    @problem = MeaningProblem.new(@item, @quiz)
            @problem.should_not be_nil
		    @problem.level.should be(1)
            @problem.question.should eql("to meet, to interview\n")
            @problem.answer.should eql("会う\nあう\nHint: No hints\n")
        end
    end
end
