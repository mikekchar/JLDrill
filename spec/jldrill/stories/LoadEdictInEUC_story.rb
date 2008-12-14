require 'jldrill/spec/StoryMemento'
require 'jldrill/model/Edict/Edict'

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
            utf = JLDrill::Edict.new
            utf.lines = ["雨"]
            utf.isUTF8?(0).should be(true)
            utf.isEUC?(0).should be(false)
            euc = JLDrill::Edict.new
            euc.lines = ["\261\253"] # EUC encoding for 雨
            euc.isUTF8?(0).should be(false)
            euc.isEUC?(0).should be(true)
            jis = JLDrill::Edict.new
            jis.lines = ["\211J"] # Shift-JIS encoding for 雨
            jis.isUTF8?(0).should be(false)
            jis.isEUC?(0).should be(false)            
        end

        it "should determine if the lines are UTF8" do
            utf = JLDrill::Edict.new
            utf.lines = ["hello", "there", "雨"]
            utf.linesAreUTF8?.should be(true)
            euc = JLDrill::Edict.new
            euc.lines = ["hello", "there", "\261\253"] # EUC encoding for 雨
            euc.linesAreUTF8?.should be(false)
            jis = JLDrill::Edict.new
            jis.lines = ["hello", "there", "\211J"] # Shift-JIS encoding for 雨
            jis.linesAreUTF8?.should be(false)
            ascii = JLDrill::Edict.new
            ascii.lines = ["hello", "there", "you"]
            ascii.linesAreUTF8?.should be(true)
        end

        it "should default to UTF8 if there are no lines in the file" do
            # Sometimes we want to parse a line without loading a file.
            empty = JLDrill::Edict.new
            empty.linesAreUTF8?.should be(true)
        end
    end

    describe Story.stepName("Edict can parse EUC entries") do

        it "should convert EUC data to UTF8" do
            euc = JLDrill::Edict.new
            euc.lines = ["\261\253 [\244\242\244\341] /(n) rain/(P)/"]
            euc.linesAreUTF8?.should be(false)
            euc.parse(euc.lines[0],0).should be(true)
            euc.vocab(0).kanji.should eql("雨")
            euc.vocab(0).reading.should eql("あめ")
        end

        # If you don't specify EUC as the input encoding, NKF sometimes
        # picks the wrong one.  Here's an example.
        it "should be able to parse いってき" do
            euc = JLDrill::Edict.new
            euc.lines = ["\260\354\332\263 [\244\244\244\303\244\306\244\255] /(n,vs) casting off or away/"]
            euc.linesAreUTF8?.should be(false)
            euc.parse(euc.lines[0],0).should be(true)
            euc.vocab(0).kanji.should eql("一擲")
            euc.vocab(0).reading.should eql("いってき")
        end
    end


end
