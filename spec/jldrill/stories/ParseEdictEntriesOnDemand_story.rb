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
            utf.parseNextLine
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
            utf.parseNextLine
            utf.length.should be(1)
            ameList = utf.search("あめ")
            ameList.size.should be(1)
            ame = ameList[0]
            ame.should_not be_nil
            ame.should eql(utf.vocab(0))
            utf.should include(ame)
        end

        it "should be able to find an entry in a real Edict" do
            utf = JLDrill::Edict.new
            utf.lines = ["雨 [あめ] /(n) rain/(P)/"]
            utf.length.should be(0)
            utf.parseNextLine
            utf.length.should be(1)
            ame = utf.vocab(0)
            ame.reading.should eql("あめ")
			dictDir = File.join(JLDrill::Config::DATA_DIR, "dict")
            filename = File.join(dictDir, "edict")
            edict = JLDrill::HashedEdict.new(filename)
            edict.read.should be(true)
            edict.length.should be(142339)
            ameList = edict.search("あめ")
            ameList.should_not be_nil
            ameList.size.should_not be(0)
            ameList.should include(ame)
            edict.should include(ame)
        end
    end
end
