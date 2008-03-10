require 'jldrill/Bin'
require 'jldrill/Vocabulary'

module JLDrill

	describe Bin do
	
		before(:each) do
        	fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/]
            @strings = fileString.split("\n")
            @strings.length.should be(4)
            @vocab = []
            0.upto(@strings.length - 1) do |i|
                 @vocab.push(Vocabulary.create(@strings[i]))
            end

            # TODO: Move this test into the Vocabulary tests when I write them
            0.upto(@vocab.length - 1) do |i|
                @vocab[i].to_s.should be_eql(@strings[i] + "\n")
            end
            
		    @bin = Bin.new("My name")
		end

		it "should have a name when constructed" do
		    @bin.name.should be_eql("My name")
		end
		
		# Pushes item on the end of bin and tests to make sure that
		# position is pos
		def test_push(pos, item)
		    @bin[pos].should be_nil
		    @bin.length.should be(pos)
		    @bin.push(item)
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
		        x.position <=> y.position
		    end
		    test_isOriginal?.should be(true)
		end
	end

end
