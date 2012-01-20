# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/model/items/JEDictionary'
require 'jldrill/model/Config'
require 'jldrill/model/Quiz/Quiz'

module JLDrill::ParseEdictEntriesOnDemand

    Story = JLDrill::StoryMemento.new("Load Edict Entries on Demand")
    def Story.setup(type)
        super(type)
#        @context = @mainContext.editVocabularyContext
#        @view = @context.peekAtView
    end

###########################################

    describe Story.stepName("Can find an entry") do

        it "should find an entry in a JEDictionary" do
            utf = JLDrill::JEDictionary.new
            utf.createLines("雨 [あめ] /(n) rain/(P)/")
            utf.encoding.should eql(Kconv::UTF8)
            utf.length.should be(0)
            utf.parse
            utf.length.should be(1)
            ameList = utf.findReadingsStartingWith("あめ")
            ameList.size.should be(1)
            ame = ameList[0]
            ame.toVocab.should eql(utf.vocab(0))
            utf.include?(ame.toVocab).should be_true
        end

        it "should be able to find an entry in an EUC edict file" do
            utf = JLDrill::JEDictionary.new
            utf.createLines("雨 [あめ] /(n) rain/(P)/")
            utf.encoding.should eql(Kconv::UTF8)
            utf.length.should be(0)
            utf.parse
            utf.length.should be(1)
            ame = utf.vocab(0)
            ame.reading.should eql("あめ")
            euc = JLDrill::JEDictionary.new
            euc.createLines("\261\253 [\244\242\244\341] /(n) rain/(P)/")
            euc.encoding.should eql(Kconv::EUC)
            euc.parse
            euc.length.should be(1)
            euc.vocab(0).should eql(ame)
            euc.length.should be(1)
            euc.dictEntries[0].reading.should eql("あめ")
            ameList = euc.findReadingsStartingWith("あめ")
            ameList.should_not be_nil
            ameList.size.should be(1)
            ameList.any? do |item|
                item.toVocab.eql?(ame)
            end.should be(true)
            euc.should include(ame)
        end

        it "should be able to find an entries in a JEDictionary" do
            edict = JLDrill::JEDictionary.new
            edict.createLines("あ /hiragana a/\n" +
                         "雨 [あめ] /(n) rain/(P)/\n" +
                         "雨降り [あめふり] /(n) in the rain/(P)/\n" +
                         "雨降らし [あめふらし] /(n) sea hare/")
            edict.encoding.should eql(Kconv::UTF8)
            edict.parse
            edict.length.should be(4)
            edict.vocab(0).reading.should eql("あ")
            edict.vocab(1).reading.should eql("あめ")
            edict.vocab(2).reading.should eql("あめふり")
            edict.vocab(3).reading.should eql("あめふらし")
            edict.include?(edict.vocab(0)).should be(true)
            edict.include?(edict.vocab(1)).should be(true)
            edict.include?(edict.vocab(2)).should be(true)
            edict.include?(edict.vocab(3)).should be(true)
            alist = edict.findReadingsStartingWith("あ")
            alist.size.should be(4)
            amelist = edict.findReadingsStartingWith("あめ")
            amelist.size.should be(3)
            amefurilist = edict.findReadingsStartingWith("あめふり")
            amefurilist.size.should be(1)
            amefurilist = edict.findReadingsStartingWith("あめが")
            amefurilist.size.should be(0)
        end
    end

    describe Story.stepName("Extra Edict tests") do

        it "should return nil from vocab() when index is out of range" do
            edict = JLDrill::JEDictionary.new
            edict.vocab(5).should be_nil
            edict.createLines("雨 [あめ] /(n) rain/(P)/")
            edict.encoding.should eql(Kconv::UTF8)
            edict.parse
            edict.length.should be(1)
            edict.vocab(5).should be_nil
        end

        it "should be able to load a Quiz from an Edict file" do
            quiz = JLDrill::Quiz.new
            quiz.length.should be(0)
            quiz.needsSave?.should be(false)
            edict = JLDrill::JEDictionary.new
            edict.createLines("あ /hiragana a/\n" +
                         "雨 [あめ] /(n) rain/(P)/\n" +
                         "雨降り [あめふり] /(n) in the rain/(P)/")
            edict.encoding.should eql(Kconv::UTF8)
            edict.parse
            quiz.loadFromDict(edict)
            quiz.length.should be(3)
            quiz.needsSave?.should be(true)
            quiz.name.should eql("No name")
        end

        it "should be able to parse hacked JLPT files" do
            # Some of the entries in the JLPT files look like this
            edict = JLDrill::JEDictionary.new
            edict.createLines("あ [（平仮名）] /hiragana a/")
            edict.encoding.should eql(Kconv::UTF8)
            edict.parse
            edict.length.should be(1)
            a = edict.vocab(0)
            a.kanji.should be_nil
            a.reading.should eql("あ")
            a.hint.should eql("平仮名")
            edict.should include(a)
            edict.findReadingsStartingWith("あ").any? do |item|
                item.toVocab.eql?(a)
            end.should be(true)
        end
    end
end
