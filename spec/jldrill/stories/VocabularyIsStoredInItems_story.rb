# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/model/Item'
require 'jldrill/model/items/Vocabulary'

module JLDrill::VocabularyIsStoredInItems

    Story = JLDrill::StoryMemento.new("Vocabulary Is Stored In Items")
    def Story.setup(type)
        super(type)
    end

###########################################

    describe Story.stepName("Items can hold Vocabulary") do
        it "should be able to create an Item from a Vocabulary" do
            vocabString = "/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 2/Consecutive: 1/MeaningProblem/Score: 0/Level: 0/Potential: 432000/\n"
            item = JLDrill::Item.create(vocabString)
            item.to_s.should eql(vocabString)
        end

        it "should be able to see if items are equal" do
            # Note: This does not check status
            v1 = "/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 2/Consecutive: 1/MeaningProblem/Score: 0/Level: 0/Potential: 432000/\n"
            v2 = "/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 3/Consecutive: 0/MeaningProblem/Score: 2/Level: 1/Potential: 176947/\n"
            v3 = "/Kanji: 雨/Reading: あめ/Definitions: rain/Markers: n,P/Position: 2/Consecutive: 1/MeaningProblem/Score: 0/Level: 0/Potential: 432000/\n"

            vocab1 = JLDrill::Vocabulary.create(v1)
            vocab2 = JLDrill::Vocabulary.create(v2)
            vocab3 = JLDrill::Vocabulary.create(v3)

            vocab1.should eql(vocab2)
            vocab1.should_not eql(vocab3)

            item1 = JLDrill::Item.new(vocab1)
            item2 = JLDrill::Item.new(vocab2)
            item3 = JLDrill::Item.new(vocab3)

            item1.should eql(item2)
            item1.should_not eql(item3)

            item1.should be_contain(vocab1)
            item1.should be_contain(vocab2)
            item1.should_not be_contain(vocab3)
        end
    end
end
