# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/model/items/JEDictionary'

module JLDrill::LoadEdictInEUC

    Story = JLDrill::StoryMemento.new("Can Load Edict in EUC")
    def Story.setup(type)
        super(type)
#        @context = @mainContext.editVocabularyContext
#        @view = @context.peekAtView
    end

###########################################

    describe Story.stepName("Edict can determine the type") do

        it "should be able to recognize utf8 and euc" do
            utf = JLDrill::JEDictionary.new
            utf.lines = ["雨"]
            utf.isUTF8?(0).should be(true)
            euc = JLDrill::JEDictionary.new
            euc.lines = ["\261\253"] # EUC encoding for 雨
            euc.isUTF8?(0).should be(false)
            jis = JLDrill::JEDictionary.new
            jis.lines = ["\211J"] # Shift-JIS encoding for 雨
            jis.isUTF8?(0).should be(false)
        end

    end

    describe Story.stepName("Edict can parse EUC entries") do

        it "should convert EUC data to UTF8" do
            euc = JLDrill::JEDictionary.new
            euc.lines = ["\261\253 [\244\242\244\341] /(n) rain/(P)/"]
            euc.parseLine(0).should_not be_nil
            euc.vocab(0).kanji.should eql("雨")
            euc.vocab(0).reading.should eql("あめ")
        end

        # If you don't specify EUC as the input encoding, NKF sometimes
        # picks the wrong one.  Here's an example.
        it "should be able to parse いってき" do
            euc = JLDrill::JEDictionary.new
            euc.lines = ["\260\354\332\263 [\244\244\244\303\244\306\244\255] /(n,vs) casting off or away/"]
            euc.parseLine(0).should_not be_nil
            euc.vocab(0).kanji.should eql("一擲")
            euc.vocab(0).reading.should eql("いってき")
        end
    end


end
