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

        it "should determine the correct RE" do
            utf = JLDrill::Edict.new
            utf.lines = ["hello", "there", "雨"]
            utf.lineRE.should be(JLDrill::Edict.const_get(:UTF8_LINE_RE))
            euc = JLDrill::Edict.new
            euc.lines = ["hello", "there", "\261\253"] # EUC encoding for 雨
            euc.lineRE.should be(JLDrill::Edict.const_get(:EUC_LINE_RE))
            jis = JLDrill::Edict.new
            jis.lines = ["hello", "there", "\211J"] # Shift-JIS encoding for 雨
            jis.lineRE.should be(nil)
            # It should default to UTF8 if both will fit
            ascii = JLDrill::Edict.new
            ascii.lines = ["hello", "there", "you"]
            ascii.lineRE.should be(JLDrill::Edict.const_get(:UTF8_LINE_RE))
        end

        it "should default to UTF8 if there are no lines in the file" do
            # Sometimes we want to parse a line without loading a file.
            # Set the parser to UTF8 unless it is already set.
            empty = JLDrill::Edict.new
            empty.lineRE.should be(JLDrill::Edict.const_get(:UTF8_LINE_RE))
            empty.setEUC
            empty.lineRE.should be(JLDrill::Edict.const_get(:EUC_LINE_RE))
            empty.setUTF8
            empty.lineRE.should be(JLDrill::Edict.const_get(:UTF8_LINE_RE))
        end

        it "should be able to set the parser to the desired setting" do
            ascii = JLDrill::Edict.new
            ascii.lines = ["hello", "there", "you"]
            ascii.lineRE.should be(JLDrill::Edict.const_get(:UTF8_LINE_RE))
            ascii.setEUC
            ascii.lineRE.should be(JLDrill::Edict.const_get(:EUC_LINE_RE))
            ascii.setUTF8
            ascii.lineRE.should be(JLDrill::Edict.const_get(:UTF8_LINE_RE))
        end
    end
end
