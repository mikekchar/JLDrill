require 'jldrill/model/Bin'
require 'jldrill/model/Vocabulary'

module JLDrill

	describe Vocabulary do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/Difficulty: 3/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/Difficulty: 3/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/Difficulty: 3/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/Consecutive: 0/Difficulty: 3/]
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @vocab = []
            0.upto(@strings.length - 1) do |i|
                 @vocab.push(Vocabulary.create(@strings[i]))
            end
		end
		
		it "should be able to parse vocabulary from strings" do
            0.upto(@vocab.length - 1) do |i|
                @vocab[i].to_s.should be_eql(@strings[i] + "\n")
            end
		end
        
        it "should be able to tell a valid vocabulary from invalid" do
            # A vocabulary is vald if it has definitions and a reading
            @vocab.each do |v|
                v.should be_valid
            end
            v2 = Vocabulary.create("/Kanji: 会う/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/")
            v2.should_not be_nil
            v2.should_not be_valid
            v3 = Vocabulary.create("/Kanji: 会う/Reading: あう/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/")
            v3.should_not be_nil
            v3.should be_valid
            v4 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/")
            v4.should_not be_nil
            v4.should be_valid
        end
        
        it "should be able to save itself as a tab separated value" do
            tsv = "会う\tあう\t(v5u, P) to meet, to interview"
            @vocab[0].to_tsv.should be_eql(tsv)
        end
       
        it "should be able to split strings on commas" do
            Vocabulary.splitCommas("a,b").should be_eql(["a","b"])
            Vocabulary.splitCommas("a, b").should be_eql(["a","b"])
            Vocabulary.splitCommas("   a   , b   ").should be_eql(["a","b"])
            Vocabulary.splitCommas(" This is it , it works ").should be_eql(["This is it","it works"])
        end
        
        it "should be able to join arrays with commas" do
            Vocabulary.joinCommas(nil).should be_eql("")
        end
        
        it "should not break the parser to try to parse nonsense" do
            v = Vocabulary.create("This is a nonsense string")
            v.should_not be_nil
            v.should_not be_valid
            v = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Difficulty: 3/Coffee: is/Great: in,the/Morning: 1/")
            v.should_not be_nil
            v.should be_valid
            v.to_s.should be_eql(@strings[0] + "\n")
        end
       
       it "should be able to assign the contents of one Vocabulary to another" do
            v1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
            v1.should be_valid
            v2 = Vocabulary.create("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 1/Level: 2/Position: 2/")
            v2.should be_valid
            v1.should_not be_eql(v2)
            v1.assign(v2)
            v1.should be_eql(v2)
            v1.status.bin.should be(0)
            v1.status.level.should be(0)
            v1.status.position.should be(1)
            v3 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/")
            v3.hint.should be_nil
            v1.hint.should_not be_nil
            v1.assign(v3)
            v1.hint.should be_nil
        end
       
       
        it "should be able to set definitions and markers" do
            v1 = Vocabulary.new
            v1.should_not be_hasDefinitions
            v1.should_not be_hasMarkers
            v1.definitions = "one, two, three"
            v1.should be_hasDefinitions
            v1.definitions.should be_eql("one, two, three")
            v1.markers = "one, two, three"
            v1.should be_hasMarkers
            v1.markers.should be_eql("one, two, three")
        end
        
        it "should set definitions and markers to nil if empty" do
            v1 = Vocabulary.new
            v1.should_not be_hasDefinitions
            v1.definitions = ""        
            v1.should_not be_hasDefinitions
            v1.should_not be_hasMarkers
            v1.markers = ""        
            v1.should_not be_hasMarkers
            v2 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions:/Markers:/Score: 0/Bin: 0/Level: 0/Position: 1/")
            v2.should_not be_hasDefinitions
            v2.should_not be_hasMarkers
        end
        
        it "should be able to set kanji, reading and hint" do
            v1 = Vocabulary.new
            v1.should_not be_hasKanji
            v1.kanji = "test"        
            v1.should be_hasKanji
            v1.kanji.should be_eql("test")
            v1 = Vocabulary.new
            v1.should_not be_hasReading
            v1.reading = "test"        
            v1.should be_hasReading
            v1.reading.should be_eql("test")
            v1 = Vocabulary.new
            v1.should_not be_hasHint
            v1.hint = "test"        
            v1.should be_hasHint
            v1.hint.should be_eql("test")
        end
        
        it "should set kanji, reading and hint to nil if empty" do
            v1 = Vocabulary.new
            v1.should_not be_hasKanji
            v1.kanji = ""        
            v1.should_not be_hasKanji
            v1.should_not be_hasReading
            v1.kanji = ""        
            v1.should_not be_hasReading
            v1 = Vocabulary.new
            v1.should_not be_hasHint
            v1.kanji = ""        
            v1.should_not be_hasHint
        end     

        ##################################################
        # From DisplayProblem story
        it "should be able to insert carriage returns" do
            vocab = Vocabulary.new()
            vocab.reading = "This is a test\\n"
		    vocab.reading.should be_eql("This is a test\n")
		    vocab.reading = "This is a test\n"
		    vocab.reading.should be_eql("This is a test\n")
        end
		    
        it "should be able to insert quotes" do
            vocab = Vocabulary.new()
		    vocab.reading = "This is a \"test\""
		    vocab.reading.should be_eql("This is a \"test\"")
        end
        ####################################################
           
	end

end
