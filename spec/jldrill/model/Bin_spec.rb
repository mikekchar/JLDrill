require 'jldrill/model/Bin'
require 'jldrill/model/items/Vocabulary'

module JLDrill

	describe Bin do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/Difficulty: 3/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/Difficulty: 3/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/Difficulty: 3/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/Consecutive: 1/Difficulty: 3/]
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @items = []
            0.upto(@strings.length - 1) do |i|
                 @items.push(Item.create(@strings[i]))
            end

		    @bin = Bin.new("My name", 42)
		end

		it "should have a name and number when constructed" do
		    @bin.name.should eql("My name")
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
		    @bin[pos].should equal(item)
		end
		
		it "should be able to push a vocabulary" do
		    test_push(0, @items[0])
		end
		
		def test_isOriginal?
		    retVal = @items.length == @bin.length
		    if retVal
		        i = 0
		        retVal = @bin.all? do |item|
		            equal = item.equal?(@items[i])
		            i += 1
		            equal
		        end
		    end
		    retVal
		end
		
		def test_pushAll
		    0.upto(@items.length - 1) do |i|
		        test_push(i, @items[i])
		    end
            test_isOriginal?.should be(true)
		end
		
		it "should be able to iterate through the bin using each()" do
		    test_pushAll
            i = 0
		    @bin.each do |item|
		        item.should eql(@items[i])
		        i += 1
		    end
		end
		
		def test_delete_at(pos)
		    @bin.delete_at(pos)
		    @bin.length.should be(@items.length - 1)
		    @bin[pos].should equal(@items[pos + 1])
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
		    test_push(@items.length - 1, @items[0])
		    test_isOriginal?.should be(false)
		    @bin.sort! do |x, y|
		        x.status.position <=> y.status.position
		    end
		    test_isOriginal?.should be(true)
		end
		
		it "should output itself in save format" do
		# Note the bin number has changed
		contentsString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 42/Level: 0/Position: 1/Consecutive: 0/Difficulty: 3/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 42/Level: 0/Position: 2/Consecutive: 0/Difficulty: 3/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 42/Level: 0/Position: 3/Consecutive: 0/Difficulty: 3/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 42/Level: 0/Position: 4/Consecutive: 1/Difficulty: 3/]
		    test_pushAll
		    @bin.to_s.should eql("My name\n" + contentsString + "\n")
		end
		
		it "should indicate if the bin is empty" do
		    bin = Bin.new("yeah", 3)
		    bin.empty?.should be(true)
		    test_pushAll
		    @bin.empty?.should be(false)
		end
		
		it "should indicate if all the items in the bin have been seen" do
		    bin = Bin.new("hi", 4)
		    bin.empty?.should be(true)
		    bin.allSeen?.should be(true)
		    test_pushAll
		    @bin.allSeen?.should be(false)
		    @bin.each do |item|
		        item.status.seen = true
		    end
		    @bin.allSeen?.should be(true)
		end

        it "should be able to find the first unseen item" do
            bin = Bin.new("hi", 4)
            bin.empty?.should be(true)
            bin.firstUnseen.should be(-1)
		    test_pushAll
		    
		    @bin.firstUnseen.should be(0)
		    @bin.contents[0].status.seen = true
		    @bin.contents[1].status.seen = true
		    @bin.firstUnseen.should be(2)
		    @bin.each do |item|
		        item.status.seen = true
		    end
            @bin.firstUnseen.should be(-1)
        end
        
        it "should be able to set all the items to unseen" do
            # First test the corner case of an empty bin
            bin = Bin.new("hi", 4)
            bin.empty?.should be(true)
            bin.firstUnseen.should be(-1)
            bin.setUnseen
            bin.empty?.should be(true)
            bin.firstUnseen.should be(-1)
            bin.allSeen?.should be(true)
           
		    test_pushAll
            @bin.firstUnseen.should be(0)
		    @bin.each do |item|
		        item.status.seen = true
		    end
            @bin.firstUnseen.should be(-1)
            @bin.setUnseen
            @bin.firstUnseen.should be(0)
        end
        
        it "should be able to count the number of unseen items" do
            bin = Bin.new("hi", 4)
            bin.empty?.should be(true)
            bin.numUnseen.should be(0)

		    test_pushAll
		    total = 4
            @bin.numUnseen.should be(total)
            @bin.each do |item|
                item.status.seen = true
                total -= 1
                @bin.numUnseen.should be(total)
            end
        end
        
        it "should be able to find the nth unseen item in the bin" do
            bin = Bin.new("hi", 4)
            bin.empty?.should be(true)
            bin.findUnseen(0).should be_nil

		    test_pushAll
		    @bin[0].status.seen = true
		    @bin[2].status.seen = true
		    @bin.findUnseen(0).should eql(@bin[1])
		    @bin.findUnseen(1).should eql(@bin[3])
        end
        
        it "should be able to tell if an item exists in the bin" do
            test_pushAll
            @bin.exists?(@bin[0]).should be(true)
            @bin.contain?(Vocabulary.create("/Kanji: 雨/Reading: あめ/Definitions: rain/Markers: n,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/Difficulty: 3/")).should be(false)
        end
	end
end
