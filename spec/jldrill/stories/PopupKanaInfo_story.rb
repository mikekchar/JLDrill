require 'jldrill/spec/StoryMemento'
require 'jldrill/model/moji/Kana'
require 'jldrill/model/Config'
require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'
require 'jldrill/views/test/FileProgress'
require 'jldrill/views/test/VBoxView'

module JLDrill::PopupKanaInfo

    Story = JLDrill::StoryMemento.new("Pop up kanji info")
    def Story.setup(type)
        super(type)
        @context = @mainContext.displayProblemContext
        @view = @context.peekAtView
    end

    describe JLDrill::Kana do
        it "should be able to parse an entry from the kana file" do
            entryText = "あ|S3|a|ah||father,law\n"
            entry = JLDrill::Kana.parse(entryText)
            entry.should_not be_nil
            entry.character.should eql("あ")
            entry.examples.size.should be(2)
            entry.examples[0].should eql("father")
            entry.examples[1].should eql("law")
            entry.strokes.should be(3)
            entry.romaji.size.should be(1)
            entry.romaji[0].should eql("a")
            entry.pronunciation.should eql("ah")
        end

        it "should be able to parse entries with multiple romaji" do
            entryText = "し|S1|shi/si|shee||she,sheep\n"
            entry = JLDrill::Kana.parse(entryText)
            entry.should_not be_nil
            entry.romaji.size.should be(2)
            entry.romaji[0].should eql("shi")
            entry.romaji[1].should eql("si")
        end

        it "should be able to create a string from the entry" do
            entryText = "し|S1|shi/si|shee||she,sheep\n"
            entry = JLDrill::Kana.parse(entryText)
            entry.should_not be_nil
            entry.to_s.should eql("し [shi si]\n" +
                                 "shee\n" +
                                 "\n" + 
                                 "Strokes: 1\n" +
                                 "\n" +
                                 "English Examples: she, sheep\n")
        end

        it "should be able to parse a file in a string" do
            string =
%Q[あ|S3|a|ah||father,law
い|S2|i|ee||keep,steer
う|S2|u|oo||boot,stupid
え|S2|e|ay||say,may
お|S3|o|oh||tone,low
]
            list = JLDrill::KanaList.fromString(string)
            list.should_not be_nil
            list.size.should be(5)
            list[0].should eql(JLDrill::Kana.parse("あ|S3|a|ah||father,law\n"))
            list[1].should eql(JLDrill::Kana.parse("い|S2|i|ee||keep,steer\n"))
            list[2].should eql(JLDrill::Kana.parse("う|S2|u|oo||boot,stupid\n"))
            list[3].should eql(JLDrill::Kana.parse("え|S2|e|ay||say,may\n"))
            list[4].should eql(JLDrill::Kana.parse("お|S3|o|oh||tone,low\n"))
        end

		it "should be able to parse a file on disk" do
			list = JLDrill::KanaList.fromFile(JLDrill::Config::getDataDir + 
                                              "/tests/kana.dat")
			list.should_not be(nil)
			list.size.should be(100)
			kana = list.findChar("じ")
			kana.should_not be_nil
		end

    end

    describe Story.stepName("The user should see kana information") do
        it "should load the kana info" do
            Story.setup(JLDrill::Test)
            Story.start
            Story.mainContext.loadKanjiContext.kanaFile = JLDrill::Config::getDataDir + "/tests/kanji.dat"
            Story.mainContext.loadKanjiContext.radicalsFile = JLDrill::Config::getDataDir + "/tests/radicals.dat"
            Story.mainContext.loadKanjiContext.kanjiFile = JLDrill::Config::getDataDir + "/tests/kanji.dat"
            Story.mainContext.loadKanji
            Story.mainContext.kana.kanaList.size.should be(100)
            Story.shutdown
        end

        it "should be able to find the kana items" do
            Story.setup(JLDrill::Test)
            Story.start
            Story.mainContext.loadKanjiContext.kanaFile = JLDrill::Config::getDataDir + "/tests/kana.dat"
            Story.mainContext.loadKanjiContext.radicalsFile = JLDrill::Config::getDataDir + "/tests/radicals.dat"
            Story.mainContext.loadKanjiContext.kanjiFile = JLDrill::Config::getDataDir + "/tests/kanji.dat"
            Story.mainContext.loadKanji
            oString = JLDrill::Kana.parse("お|S3|o|oh||tone,low\n").to_s
            Story.context.kanjiInfo("お").should eql(oString)
            Story.shutdown
        end
    end

end
