# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/model/items/Vocabulary'

module JLDrill::ClosestMatch
    
    Story = JLDrill::StoryMemento.new("Find the closest match")
    
    describe Story.stepName("Find the number of common bytes") do

        it "should return 0 for dissimilar strings" do
            vocab = JLDrill::Vocabulary.new
            string1 = "hello"
            string2 = "boris"
            vocab.numCommonChars(string1, string2).should be(0)
        end

        it "should count common characters at the beginning of the string" do
            vocab = JLDrill::Vocabulary.new
            vocab.numCommonChars("hello", "helpers").should be(3)
            vocab.numCommonChars("hell", "hello there").should be(4)
            vocab.numCommonChars("hellow there", "hell").should be(4)
        end

        it "should return 0 for empty and nil strings" do
            vocab = JLDrill::Vocabulary.new
            vocab.numCommonChars(nil, "Hello").should be(0)
            vocab.numCommonChars("", "Hello").should be(0)
            vocab.numCommonChars("Hello", nil).should be(0)
            vocab.numCommonChars("Hello", "").should be(0)
        end

        it "should work with UTF-8 characters" do
            vocab = JLDrill::Vocabulary.new
            vocab.numCommonChars("あめ", "あめずけ"). should be(2)
            vocab.numCommonChars("あめ", "あめがふっています").should be(2)
            vocab.numCommonChars("あめ", "雨").should be(0)
            vocab.numCommonChars("雨", "雨が降っています").should be(1)
        end
    end

        
    describe Story.stepName("Find the rank between two vocabs") do

        it "should return 0 for nil objects" do
            vocab = JLDrill::Vocabulary.new
            vocab.rank(nil).should be(0)
        end

        it "should return the number of common bytes in the reading" do
            ame = JLDrill::Vocabulary.create("/Reading: あめ/")
            hitotsu = JLDrill::Vocabulary.create("/Reading: ひとつ/")
            ame.rank(hitotsu).should be(0)
            amegafutteiru = JLDrill::Vocabulary.create("/Reading: あめがふっている")
            ame.rank(amegafutteiru).should be(2000)
            ame.rank(ame).should be(2000)
        end

        it "should use the kanji if it exists" do
            ame0 = JLDrill::Vocabulary.create("/Reading: あめ/")
            ame1 = JLDrill::Vocabulary.create("/Kanji: 雨/Reading: あめ/")
            ame2 = JLDrill::Vocabulary.create("/Kanji: 天/Reading: あめ/")
            ame0.rank(ame1).should be(2000)
            ame1.rank(ame1).should be(2100)
            ame1.rank(ame2).should be(2000)
        end

        it "should use the definitions" do
            aoi = JLDrill::Vocabulary.create("/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced")
            aoi2 = JLDrill::Vocabulary.create("/Reading: あおい/Definitions: blue, green, anime character/")
            aoi.rank(aoi2).should be(3009)
        end

        it "should use the markers" do
            verb = JLDrill::Vocabulary.create("/Kanji: 行く/Reading: いく/Markers: v5k-s,vi,P/")
            noun = JLDrill::Vocabulary.create("/Kanji: 幾/Reading: いく/Markers: n,pref,P/")
            verb.rank(noun).should be(2001)
        end
    end
end
