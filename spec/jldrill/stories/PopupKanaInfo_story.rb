require 'jldrill/spec/StoryMemento'
require 'jldrill/model/Kana'

module JLDrill::PopupKanaInfo

    Story = JLDrill::StoryMemento.new("Pop up kanji info")
    def Story.setup(type)
        super(type)
#        @context = @mainContext.displayProblemContext
#        @view = @context.peekAtView
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
    end

    describe Story.stepName("The user should load kana information") do
        it "should load the kana info" do
            
        end
        
    end

end
