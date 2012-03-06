# encoding: utf-8
require 'jldrill/model/Quiz'
require 'jldrill/model/quiz/Contents'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/model/quiz/Strategy'

module JLDrill

	describe Contents do
	
	    before(:each) do
	        @sampleQuiz = SampleQuiz.new
	        @quiz = @sampleQuiz.quiz
	    end
	    
        it "should add items to the last position if the position is set to -1" do
        	item = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
            item.position = -1
	        @quiz.contents.bins[Strategy.reviewSetBin].length.should be(2)
	        @quiz.contents.addItem(item, Strategy.reviewSetBin)
	        @quiz.contents.bins[Strategy.reviewSetBin].length.should be(3)
	        # This is the 5th item counting from 0.  There are already 2
	        # items in the review bin, so it should put it at the end.
	        @quiz.contents.bins[Strategy.reviewSetBin][2].position.should be(4)
	    end
	    
	    it "should be able to print out the status" do
            @quiz.contents.bins[Strategy.reviewSetBin][1].schedule.scheduled?.should be(true)
    	    @quiz.contents.status.should eql("New: 1 Review: 2 Working: 1")
	    end
	    
	    def countSizes(sizes, range)
	        total = 0
	        range.each do |i|
	            total += sizes[i]
	        end
	        total
	    end
	    
	    it "should be able to add items to the contents only if they dont already exist" do
            item = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
            @quiz.contents.addUniquely(item).should be(true)
            item.position.should be(4)

            # We just added this one
            existingItem = QuizItem.new(@quiz, @sampleQuiz.sampleVocab)
            @quiz.contents.addUniquely(existingItem).should be(false)
	    end
	    
	    it "should be able to add the contents from another quiz to this one" do
	        quiz2 = Quiz.new

            quiz2.loadFromString("testFile", @sampleQuiz.file)
            item = QuizItem.new(quiz2, @sampleQuiz.sampleVocab)
            quiz2.contents.addItem(item, Strategy.reviewSetBin)
            quiz2.contents.length.should be(5)
            quiz2.contents.bins[Strategy.reviewSetBin].length.should eql(3)
            quiz2.contents.bins[Strategy.reviewSetBin][2].to_o.kanji.should eql(item.to_o.kanji)

	        @quiz.contents.addContents(quiz2.contents)
	        @quiz.contents.length.should be(5)
            quiz2.contents.bins[Strategy.reviewSetBin].length.should eql(3)
            @quiz.contents.bins[Strategy.reviewSetBin][2].to_o.kanji.should eql(item.to_o.kanji)
	    end
    end
end
