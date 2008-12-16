require 'jldrill/spec/StoryMemento'
require 'jldrill/model/Edict/Edict'
require 'jldrill/model/HashedEdict'
require 'jldrill/model/Config'

module JLDrill::ParseEdictEntriesOnDemand

    Story = JLDrill::StoryMemento.new("Load Edict Entries on Demand")
    def Story.setup(type)
        super(type)
#        @context = @mainContext.editVocabularyContext
#        @view = @context.peekAtView
    end

###########################################

    describe Story.stepName("Can find an entry") do

        it "should be able to parse readings" do
            utf = JLDrill::Edict.new
            utf.parseReading("雨 [あめ] /(n) rain/(P)/").should eql("あめ")
        end

        it "should find an entry in an Edict" do
            utf = JLDrill::Edict.new
            utf.lines = ["雨 [あめ] /(n) rain/(P)/"]
            utf.length.should be(0)
            utf.parseLines
            utf.length.should be(1)
            ameList = utf.search("あめ")
            ameList.size.should be(1)
            ame = ameList[0]
            ame.should_not be_nil
            ame.should eql(utf.vocab(0))
            utf.should include(ame)
        end

        it "should find an entry in an HashedEdict" do
            utf = JLDrill::HashedEdict.new
            utf.lines = ["雨 [あめ] /(n) rain/(P)/"]
            utf.length.should be(0)
            utf.parseLines
            utf.length.should be(1)
            ameList = utf.search("あめ")
            ameList.size.should be(1)
            ame = ameList[0]
            ame.should_not be_nil
            ame.should eql(utf.vocab(0))
            utf.should include(ame)
        end

        it "should be able to find an entry in an EUC edict file" do
            utf = JLDrill::Edict.new
            utf.lines = ["雨 [あめ] /(n) rain/(P)/"]
            utf.length.should be(0)
            utf.parseLines
            utf.length.should be(1)
            ame = utf.vocab(0)
            ame.reading.should eql("あめ")
            euc = JLDrill::Edict.new
            euc.lines = ["\261\253 [\244\242\244\341] /(n) rain/(P)/"]
            euc.parseLines
            euc.linesAreUTF8?.should be(false)
            euc.length.should be(1)
            euc.vocab(0).should eql(ame)
            euc.readings.size.should be(1)
            euc.readings[0].should eql("あめ")
            ameList = euc.search("あめ")
            ameList.should_not be_nil
            ameList.size.should be(1)
            ameList.should include(ame)
            euc.should include(ame)
        end

        it "should be able to find an entries in a HashedEdictFile" do
            edict = JLDrill::HashedEdict.new
            edict.lines = ["あ /hiragana a/",
                         "雨 [あめ] /(n) rain/(P)/",
                         "雨降り [あめふり] /(n) in the rain/(P)/"]
            edict.parseLines
            edict.length.should be(3)
            edict.vocab(0).reading.should eql("あ")
            edict.vocab(1).reading.should eql("あめ")
            edict.vocab(2).reading.should eql("あめふり")
            edict.include?(edict.vocab(0)).should be(true)
            edict.include?(edict.vocab(1)).should be(true)
            edict.include?(edict.vocab(2)).should be(true)
        end
    end
end
