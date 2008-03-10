require 'jldrill/Quiz'

module JLDrill

	describe Bin do
	
		before(:each) do
        	fileString = %Q[0.2.0-LDRILL-SAVE Testfile
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/
]
		    @quiz = Quiz.new
		end

		it "should have a name when constructed" do
		    @quiz.should_not be_nil
		end
    end
end
