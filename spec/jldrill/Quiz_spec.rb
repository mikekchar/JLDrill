require 'jldrill/Quiz'

module JLDrill

	describe Quiz do
	
		before(:each) do
        	@fileString = %Q[0.2.0-LDRILL-SAVE Testfile
# This is the info line
Random Order
Promotion Threshold: 4
Introduction Threshold: 17
Unseen
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/
Poor
Fair
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 2/Level: 0/Position: 2/
Good
Excellent
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 4/Level: 0/Position: 3/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 4/Level: 0/Position: 4/
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
		
    end
end
