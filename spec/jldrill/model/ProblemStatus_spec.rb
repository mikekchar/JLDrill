# encoding: utf-8
require 'jldrill/model/quiz/ProblemStatus'
require 'jldrill/model/Quiz'

module JLDrill

	describe ProblemStatus do
	
		before(:each) do
		    @quiz = Quiz.new
		    @vocab = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/")
		    @item = @quiz.contents.add(@vocab, 0)
		    @status = ProblemStatus.new(@quiz, @item)
        end
        
        it "should react sanely when empty" do
            @status.currentlyParsing.should eql(-1)
            clone = @status.clone
            clone.currentlyParsing.should eql(-1)
        end

        def testParse(type)
            current = @status.currentlyParsing
            @status.parse(type).should be(true)
            @status.currentlyParsing.should eql(current + 1)
            @status.schedules[current + 1].problemType.should eql(type)
            @status.schedules[current + 1].should_not be_nil
            @status.schedules[current + 1].score.should be(0)
            @status.parse("Score: 5").should be(true)
            @status.schedules[current + 1].score.should be(5)
        end

        it "should create schedules for each problem type it recognizes" do
            @status.currentlyParsing.should eql(-1)
            testParse("ReadingProblem")
            testParse("KanjiProblem")
            testParse("MeaningProblem")
            @status.parse("blahblahblah").should be(false)
            @status.currentlyParsing.should eql(2)
        end

        it "should output to save file format" do
            @status.to_s.should eql("")
            testParse("ReadingProblem")
            @status.to_s.should eql("/ReadingProblem/Score: 5/Potential: 432000")
            testParse("KanjiProblem")
            @status.to_s.should eql("/ReadingProblem/Score: 5/Potential: 432000/KanjiProblem/Score: 5/Potential: 432000")
        end

        it "should be able to clone" do
            testParse("ReadingProblem")
            testParse("KanjiProblem")
            testParse("MeaningProblem")
            clone = @status.clone
            clone.to_s.should eql(@status.to_s)
        end
    end
end
