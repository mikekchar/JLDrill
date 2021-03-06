# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/contexts/EditVocabularyContext'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/items/JEDictionary'

# This story discusses the input and output of data in
# Vocabulary.  As I slowly removed my assumptions about
# what a Vocabulary could store, I discovered that I
# had to be more and more tricky about storing it.  I decided
# I needed a separate story to ensure that it works in
# all cases.
# Note: I noticed that I never wrote any tests for EditVocabularyContext
# originally.  I suspect that the lack of functionality I'm experiencing
# is directly related to that failure.

# Background:
#  Some characters must have special processing and must be tested.
#  These characters are:
#
#    Character     Stored as      Entered as        Reason
#       "             "                "            ruby string delimeter
#     return          \n          return or \n      end of line delimeter
#       ,             \,             , or \,        definition/marker delimeter
#       /             \/            \/ or /         field delimeter
#
# Comma *must* be entered as \, in definitions and markers at the present 
# time, but can be entered as , in the other fields.
#
# Programatically, the fields have 2 accessors:
#    plain -- i.e., kanji reading definitions markers hint
#    raw   -- i.e., kanjiRaw readingRaw definitionsRaw markersRaw hintRaw
#
# Plain accessors access the information in human readable way.
# In other words \" becomes ", etc.  Raw accessors access the information
# as they are stored (with \", \n, \,).  However definitionsRaw and
# markersRaw are still a single string with array values joined with ", ".
# definitions and markers arrays can be accessed with definitionsArray
# and markersArray respectively.
#
# Note that the above is all completely insane and due to a lack of
# proper testing/refactoring.  Unfortunately, it is the 11th hour
# for version 0.3.0 and I don't want to introduce a major file format
# change.  Please expect this to change for version 0.4.0.


module JLDrill::VocabularyIO

    Story = JLDrill::StoryMemento.new("Can Input and Output Vocabularies")
    def Story.setup(type)
        super(type)
        @context = @mainContext.editVocabularyContext
        @view = @context.peekAtView
    end

###########################################

    describe Story.stepName("Special characters should be entered properly.") do

        def testInput(vocab, field, string, raw, plain)
            eval "vocab.#{field} = string"
            eval "vocab.#{field}Raw.should eql(raw)"
            eval "vocab.#{field}.should eql(plain)"
        end

        def testQuotes(vocab, field)
            testInput(vocab, field, "\"hello\"",
                      "\"hello\"", "\"hello\"")
        end

        it "should handle quotes" do
            vocab = JLDrill::Vocabulary.new
            testQuotes(vocab, "kanji")
            testQuotes(vocab, "reading")
            testQuotes(vocab, "hint")
            testQuotes(vocab, "definitions")
            testQuotes(vocab, "markers")
        end

        def testListQuotes(vocab, field, list)
            rawJoinedList = "\"" + list.join(",") + "\""
            outJoinedList = "\"" + list.join(", ") + "\""
            eval "vocab.#{field} = #{rawJoinedList}"
            eval "vocab.#{field}Array.size.should be(3)"
            0.upto(2) do |i|
                listItem = "\"" + list[i] + "\""
                eval "vocab.#{field}Array[#{i}].should eql(#{listItem})"
            end
            eval "vocab.#{field}Raw.should eql(#{rawJoinedList})"
            eval "vocab.#{field}.should eql(#{outJoinedList})"
        end

        it "should handle definition and marker lists with quotes" do
            vocab = JLDrill::Vocabulary.new
            list = ["hello", "\\\"hello\\\"", "he\\\"llo"]
            testListQuotes(vocab, "definitions", list)
            testListQuotes(vocab, "markers", list)
        end

        def testReturns(vocab, field)
            testInput(vocab, field, "\nhello\n",
                      "\\nhello\\n", "\nhello\n")
            testInput(vocab, field, "\\nhello\\n",
                      "\\nhello\\n", "\nhello\n")
        end

        it "should handle returns" do
            vocab = JLDrill::Vocabulary.new
            testReturns(vocab, "kanji")
            testReturns(vocab, "reading")
            testReturns(vocab, "hint")
            testReturns(vocab, "definitions")
            testReturns(vocab, "markers")            
        end

        def testList(vocab, field, list, rawList)
            rawJoinedList = rawList.join(",")
            outJoinedList = list.join(", ")
            eval "vocab.#{field} = rawJoinedList"
            eval "vocab.#{field}Array.size.should be(3)"
            eval "vocab.#{field}Array.should eql(rawList)"
            eval "vocab.#{field}Raw.should eql(rawJoinedList)"
            eval "vocab.#{field}.should eql(outJoinedList)"
        end

        it "should handle definition and marker lists with returns" do
            vocab = JLDrill::Vocabulary.new
            list = ["hello", "\nhello\n", "he\nllo"]
            rawList = ["hello", "\\nhello\\n", "he\\nllo"]
            testList(vocab, "definitions", list, rawList)
            testList(vocab, "markers", list, rawList)
        end

        def testCommas(vocab, field)
            testInput(vocab, field, "hello\\, world",
                      "hello\\, world", "hello, world")
        end

        it "should handle commas" do
            vocab = JLDrill::Vocabulary.new
            testCommas(vocab, "kanji")
            testCommas(vocab, "reading")
            testCommas(vocab, "hint")
            testCommas(vocab, "definitions")
            testCommas(vocab, "markers")            
        end

        it "should be able to handle akeru" do
            v = JLDrill::Vocabulary.create("/Kanji: 開ける/Reading: あける/Definitions: (1) to open,(2) to unwrap (e.g.\\, parcel\\, package)/Markers: v1,P/Position: 0/Score: 0/Consecutive: 0/Difficulty:0")
            v.kanji.should eql("開ける")
            v.reading.should eql("あける")
            v.definitions.should eql("(1) to open, (2) to unwrap (e.g., parcel, package)")
            v.markers.should eql("v1, P")
        end

        it "should be able to handle tojiru" do
            edictString = "閉じる [とじる] " + 
                "/(v1) to close (e.g., book, eyes, meeting, etc.)" +
                "/to shut/(P)/\n"
            edict = JLDrill::JEDictionary.new
            edict.lines = [edictString]
            edict.parseLine(0).should_not be_nil
            v = JLDrill::Vocabulary.create("/Kanji: 閉じる" + 
                "/Reading: とじる" +
                "/Definitions: to close (e.g.\\, book\\, eyes\\, meeting\\, etc.)," +
                "to shut" +
                "/Markers: v1,P/Position: 0" +
                "/Score: 0" +
                "/Consecutive: 0/Difficulty: 0")
            edict.vocab(0).should eql(v)
        end

        def testSlashes(vocab, field)
            testInput(vocab, field, "\\/home\\/mike\\/",
                      "\\/home\\/mike\\/", "/home/mike/")
        end

        it "should handle slashes" do
            vocab = JLDrill::Vocabulary.new
            testSlashes(vocab, "kanji")
            testSlashes(vocab, "reading")
            testSlashes(vocab, "hint")
            testSlashes(vocab, "definitions")
            testSlashes(vocab, "markers")
            vocab.kanji = "\\/home\\/mike\\/"
            vocab.reading = "\\/home\\/mike\\/"
            vocab.hint = "\\/home\\/mike\\/"
            vocab.definitions = "\\/home\\/mike\\/"
            vocab.markers = "\\/home\\/mike\\/"
            vocab2 = JLDrill::Vocabulary.create(vocab.to_s)
            vocab2.should eql(vocab)
        end

    end

###########################################

    describe Story.stepName("EditVocabularyContext") do

        before(:each) do
            Story.setup(JLDrill)
            Story.start
        end

        after(:each) do
            Story.shutdown
        end

#        it "should test the data through EditVocabularyContext"
    end
end
