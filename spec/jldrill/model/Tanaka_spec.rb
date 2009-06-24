require 'jldrill/model/Tanaka'

module JLDrill
    describe Tanaka do

        it "should be able to parse an entry from the Tanaka file" do
            entryText =  "A: 何ですか？\tWhat is it?#ID=203\n"
            entryText += "B: 何{なん} です か\n"
            tanaka = Tanaka.new
            tanaka.numSentences.should be(0)
            tanaka.numWords.should be(0)
            tanaka.parse(entryText).should be(true)
            tanaka.numSentences.should be(1)
            tanaka.numWords.should be(3)
            sentences = tanaka.search("です")
            sentences.should_not be_nil
            sentences.should_not be_empty
            sentences.size.should be(1)
            sentences[0].should eql("何ですか？\tWhat is it?")
            sentences = tanaka.search("Fail")
            sentences.should_not be_nil
            sentences.should be_empty
            sentences = tanaka.search("何")
            sentences.should_not be_empty
            sentences.size.should be(1)
            sentences[0].should eql("何ですか？\tWhat is it?")            
        end
    end
end
