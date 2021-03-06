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

    describe Story.stepName("Edict can parse EUC entries") do

        it "should convert EUC data to UTF8" do
            euc = JLDrill::JEDictionary.new
            euc.createLines("\261\253 [\244\242\244\341] /(n) rain/(P)/")
            euc.encoding.should eql(Kconv::EUC)
            euc.parseLine(0).should_not be_nil
            euc.vocab(0).kanji.should eql("雨")
            euc.vocab(0).reading.should eql("あめ")
        end

        # If you don't specify EUC as the input encoding, NKF sometimes
        # picks the wrong one.  Here's an example.
        it "should be able to parse いってき" do
            euc = JLDrill::JEDictionary.new
            euc.createLines("\260\354\332\263 [\244\244\244\303\244\306\244\255] /(n,vs) casting off or away/")
            euc.encoding.should eql(Kconv::EUC)
            euc.parseLine(0).should_not be_nil
            euc.vocab(0).kanji.should eql("一擲")
            euc.vocab(0).reading.should eql("いってき")
        end
    end


end
