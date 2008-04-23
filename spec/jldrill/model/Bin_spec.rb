require 'jldrill/model/Bin'
require 'jldrill/model/Vocabulary'

module JLDrill

	describe Bin do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/Consecutive: 1/]
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @vocab = []
            0.upto(@strings.length - 1) do |i|
                 @vocab.push(Vocabulary.create(@strings[i]))
            end

            # TODO: Move this test into the Vocabulary tests when I write them
            0.upto(@vocab.length - 1) do |i|
                @vocab[i].to_s.should be_eql(@strings[i] + "\n")
            end
            
		    @bin = Bin.new("My name", 42)
		end

		it "should have a name and number when constructed" do
		    @bin.name.should be_eql("My name")
		    @bin.number.should be(42)
		end
		
		# Pushes item on the end of bin and tests to make sure that
		# position is pos
		def test_push(pos, item)
		    @bin[pos].should be_nil
		    @bin.length.should be(pos)
		    @bin.push(item)
		    item.status.bin.should be(@bin.number)
		    item.status.index.should be(pos)
		    @bin.length.should be(pos + 1)
		    @bin[pos].should_not be_nil
		    @bin[pos].to_s.should be_eql(item.to_s)
		end
		
		it "should be able to push a vocabulary" do
		    test_push(0, @vocab[0])
		end
		
		def test_isOriginal?
		    retVal = @vocab.length == @bin.length
		    if retVal
		        i = 0
		        retVal = @bin.all? do |v|
		            equal = v.to_s.eql?(@vocab[i].to_s)
		            i += 1
		            equal
		        end
		    end
		    retVal
		end
		
		def test_pushAll
		    0.upto(@vocab.length - 1) do |i|
		        test_push(i, @vocab[i])
		    end
		    i = 0
		    @bin.each do |v|
		        v.to_s.should be_eql(@vocab[i].to_s)
		        i += 1
		    end
		end
		
		it "should be able to iterate though the vocabulary" do
		    test_pushAll
		end
		
		def test_delete_at(pos)
		    @bin.delete_at(pos)
		    @bin.length.should be(@vocab.length - 1)
		    @bin[pos].to_s.should be_eql(@vocab[pos + 1].to_s)
		end
		
		it "should be able to delete an item at a position" do
		    test_pushAll
		    test_delete_at(2)
		end
		
		it "should be able to sort" do
		    test_pushAll
		    test_isOriginal?.should be(true)
		    # Remove the second one
		    test_delete_at(0)
		    test_isOriginal?.should be(false)
		    # insert it at the end
		    test_push(@vocab.length - 1, @vocab[0])
		    test_isOriginal?.should be(false)
		    @bin.sort! do |x, y|
		        x.status.position <=> y.status.position
		    end
		    test_isOriginal?.should be(true)
		end
		
		it "should output itself in save format" do
		# Note the bin number has changed
		contentsString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 42/Level: 0/Position: 1/Consecutive: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 42/Level: 0/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 42/Level: 0/Position: 3/Consecutive: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 42/Level: 0/Position: 4/Consecutive: 1/]
		    test_pushAll
		    @bin.to_s.should be_eql("My name\n" + contentsString + "\n")
		end
		
		it "should be able to create a copy of it's contents" do
		    test_pushAll
		    i = -1
		    @bin.cloneContents.all? do |vocab|
		        i += 1
		        vocab == @bin[i]
		    end.should be(true)
		    @bin.cloneContents.should_not be(@bin.contents) 
		end
		
		it "should be able to replace it's contents array" do
		# Note the bin number has changed
		contentsString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 2/Level: 0/Position: 1/Consecutive: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 2/Level: 0/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 2/Level: 0/Position: 3/Consecutive: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 2/Level: 0/Position: 4/Consecutive: 1/
]
		    test_pushAll
	        bin2 = Bin.new("number2", 2)
	        bin2.contents = @bin.cloneContents
	        bin2.to_s.should be_eql("number2\n" + contentsString)
		end
	end

end
