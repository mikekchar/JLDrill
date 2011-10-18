# encoding: utf-8
#require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/spec/StoryMemento'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::PopupKanjiInfo

    Story = JLDrill::StoryMemento.new("Pop up kanji info")
    def Story.setup(type)
        super(type)
        @context = @mainContext.displayProblemContext
        @view = @context.peekAtView
    end


    describe Story.stepName("The user should see kanji information") do

        def loadKanji
            Story.mainContext.loadKanjiContext.kanaFile = JLDrill::Config::getDataDir + "/tests/kanji.dat"
            Story.mainContext.loadKanjiContext.radicalsFile = JLDrill::Config::getDataDir + "/tests/radicals.dat"
            Story.mainContext.loadKanjiContext.kanjiFile = JLDrill::Config::getDataDir + "/tests/kanji.dat"
            Story.mainContext.loadKanji
        end

        it "should load the kanji info" do
            Story.setup(JLDrill::Test)
            Story.start
            loadKanji()
            Story.mainContext.kanji.kanjiList.size.should be(100)
            Story.shutdown
        end

        it "should be able to find the kanji items" do
            Story.setup(JLDrill::Test)
            Story.start
            loadKanji()
            Story.mainContext.kanji.kanjiList.size.should be(100)
            oString = JLDrill::Kanji.parse("事|B6 G3 S8 F18 N272 V71 H3567 DK2220 L1156 IN80 P4-8-3 I0a8.15 Yshi4|ジ ズ こと つか.う つか.える|ろ||matter, thing, fact, business, reason, possibly\n").withRadical_to_s(Story.mainContext.radicals.radicalList)
            Story.context.kanjiInfo("事").should eql(oString)
            Story.shutdown
        end

    end

end
