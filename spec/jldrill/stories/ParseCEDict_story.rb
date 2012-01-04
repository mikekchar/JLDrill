# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/model/items/CEDictionary'

module JLDrill::ParseCEDict

    Story = JLDrill::StoryMemento.new("Can parse CEDict dictionary.")
    def Story.setup(type)
        super(type)
#        @context = @mainContext.editVocabularyContext
#        @view = @context.peekAtView
    end

###########################################

    describe Story.stepName("CEDictionary can parse entries") do

        it "should read CEDict entries" do
            cedict = JLDrill::CEDictionary.new
            cedict.createLines("下雨 下雨 [xia4 yu3] /to rain/rainy/")
            cedict.parseLine(0).should_not be_nil
            cedict.vocab(0).kanji.should eql("下雨")
            cedict.vocab(0).reading.should eql("xia4 yu3")
        end
    end
end
