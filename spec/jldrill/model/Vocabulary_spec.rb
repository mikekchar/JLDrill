# -*- coding: utf-8 -*-
require 'jldrill/model/Bin'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/items/JEDictionary'

module JLDrill

	describe Vocabulary do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj]
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @vocab = []
            0.upto(@strings.length - 1) do |i|
                 @vocab.push(Vocabulary.create(@strings[i]))
            end
		end
		
		it "should be able to parse vocabulary from strings" do
            0.upto(@vocab.length - 1) do |i|
                @vocab[i].to_s.should eql(@strings[i])
            end
		end
        
        it "should be able to tell a valid vocabulary from invalid" do
            # A vocabulary is vald if it has definitions and a reading
            @vocab.each do |v|
                v.should be_valid
            end
            v2 = Vocabulary.create("/Kanji: 会う/Definitions: to meet,to interview/Markers: v5u,P")
            v2.should_not be_nil
            v2.should_not be_valid
            v3 = Vocabulary.create("/Kanji: 会う/Reading: あう/Markers: v5u,P")
            v3.should_not be_nil
            v3.should be_valid
            v4 = Vocabulary.create("/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P")
            v4.should_not be_nil
            v4.should be_valid
        end
        
        it "should not break the parser to try to parse nonsense" do
            v = Vocabulary.create("This is a nonsense string")
            v.should_not be_nil
            v.should_not be_valid
            v = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Coffee: is/Great: in,the/Morning: 1")
            v.should_not be_nil
            v.should be_valid
            v.to_s.should eql(@strings[0])
        end
       
       it "should be able to assign the contents of one Vocabulary to another" do
            v1 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P")
            v1.should be_valid
            v2 = Vocabulary.create("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P")
            v2.should be_valid
            v1.should_not eql(v2)
            v1.assign(v2)
            v1.should eql(v2)
            v3 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P")
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
            v1.definitions.should eql("one, two, three")
            v1.markers = "one, two, three"
            v1.should be_hasMarkers
            v1.markers.should eql("one, two, three")
        end
        
        it "should set definitions and markers to nil if empty" do
            v1 = Vocabulary.new
            v1.should_not be_hasDefinitions
            v1.definitions = ""        
            v1.should_not be_hasDefinitions
            v1.should_not be_hasMarkers
            v1.markers = ""        
            v1.should_not be_hasMarkers
            v2 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions:/Markers:")
            v2.should_not be_hasDefinitions
            v2.should_not be_hasMarkers
        end
        
        it "should be able to set kanji, reading and hint" do
            v1 = Vocabulary.new
            v1.should_not be_hasKanji
            v1.kanji = "test"        
            v1.should be_hasKanji
            v1.kanji.should eql("test")
            v1 = Vocabulary.new
            v1.should_not be_hasReading
            v1.reading = "test"        
            v1.should be_hasReading
            v1.reading.should eql("test")
            v1 = Vocabulary.new
            v1.should_not be_hasHint
            v1.hint = "test"        
            v1.should be_hasHint
            v1.hint.should eql("test")
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
		    vocab.reading.should eql("This is a test\n")
		    vocab.reading = "This is a test\n"
		    vocab.reading.should eql("This is a test\n")
        end
		    
        it "should be able to insert quotes" do
            vocab = Vocabulary.new()
		    vocab.reading = "This is a \"test\""
		    vocab.reading.should eql("This is a \"test\"")
        end
        ####################################################
           
        it "should be able to make a clone" do
            v = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions:/Markers:")
            v2 = v.clone
            v.should eql(v2)
        end

        # The comma in the definitions is causing problems because it is
        # used as a separator for definitions.  Edict uses slashes, so
        # it doesn't cause a problem.  Yes, it was stupid to use commas
        # in the file format; assuming that they wouldn't be used.
        # So now in the Edict file format escaping the comma with a backslash.
        # Here I convert it to a normal comma.
        # This is a complete hack, of course, and I'll have to revamp
        # the fileformat in the next version.
        it "should parse commas properly" do
            v1 = Vocabulary.create("/Kanji: 鈍い/Reading: にぶい/Definitions: dull (e.g.\\, a knife),thickheaded,slow (opposite of fast),stupid/Markers: adj,P")
            line = "鈍い [にぶい] /(adj) dull (e.g., a knife)/thickheaded/slow (opposite of fast)/stupid/(P)/"
            edict = JEDictionary.new
            edict.lines = [line]
            edict.parseLine(0)
            edict.vocab(0).should eql(v1)
            v2 = edict.vocab(0).clone
            edict.vocab(0).should eql(v2)
        end

        it "should have a hash based on the reading and kanji" do
            v1 = Vocabulary.new
            v2 = Vocabulary.new
            v1.hash.should eql(v2.hash)
            v3 = Vocabulary.create("/Kanji: 会う/Reading: あう/")
            v1.hash.should_not eql(v3.hash)
            v4 = Vocabulary.create("/Kanji: 会う/Reading: あう/Definitions: blah, blah/")
            v3.hash.should eql(v4.hash)
            v5 = Vocabulary.create("/Kanji: 会います/Reading: あう/")
            v3.hash.should_not eql(v5.hash)
            v6 = Vocabulary.create("/Kanji: 会う/Reading: あいます/")
            v3.hash.should_not eql(v6.hash)
        end
	end
end
