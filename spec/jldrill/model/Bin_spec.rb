# encoding: utf-8
require 'jldrill/model/Bin'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/Quiz'

module JLDrill

  describe Bin do

    before(:each) do
      @quiz = Quiz.new()
      @fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Consecutive: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Position: 3/Consecutive: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 4/Consecutive: 1/]
      @strings = @fileString.split("\n")
      @strings.length.should be(4)
      @items = []
      0.upto(@strings.length - 1) do |i|
        @items.push(QuizItem.create(@quiz, @strings[i], 0))
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
      item.state.bin.should be(@bin.number)
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
      item = @bin[pos]
      @bin.delete(item)
      @bin.length.should be(@items.length - 1)
      @bin[pos].should equal(@items[pos + 1])
    end

    it "should be able to delete an item" do
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
        x.state.position <=> y.state.position
      end
      test_isOriginal?.should be(true)
    end

    it "should output itself in save format" do
      contentsString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Consecutive: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Position: 3/Consecutive: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 4/Consecutive: 1/]
      test_pushAll
      @bin.to_s.should eql("My name\n" + contentsString + "\n")
    end

    it "should indicate if the bin is empty" do
      bin = Bin.new("yeah", 3)
      bin.empty?.should be(true)
      test_pushAll
      @bin.empty?.should be(false)
    end

    it "should be able to tell if an item exists in the bin" do
      test_pushAll
      @bin.exists?(@bin[0]).should be(true)
      @bin.contain?(Vocabulary.create("/Kanji: 雨/Reading: あめ/Definitions: rain/Markers: n,P/Position: 1/Consecutive: 0/")).should be(false)
    end
  end

  describe "New Bin specs" do
    describe "Names" do
      it "should have a name and number" do
        bin = Bin.new("bin-name", 5)
        expect(bin.number).to eq(5)
        expect(bin.isCalled?("bin-name")).to be_true
        expect(bin.isCalled?("Frank")).to be_false
      end

      it "has a variety of aliases" do
        bin = Bin.new("bin-name", 5)
        bin.addAliases(["Tom", "Dick", "Harry"])
        expect(bin.isCalled?("bin-name")).to be_true
        expect(bin.isCalled?("Tom")).to be_true
        expect(bin.isCalled?("Dick")).to be_true
        expect(bin.isCalled?("Harry")).to be_true
        expect(bin.isCalled?("Frank")).to be_false
      end
    end

    context "An empty bin" do
      subject(:bin) do
        Bin.new("bin-name", 5)
      end

      let(:item1) do
        Item.new()
      end

      let(:item2) do
        Item.new()
      end

      it "has a size/length of 0" do
        expect(bin.length).to eq(0)
        expect(bin.size).to eq(0)
      end

      it "returns nil for items that don't exist" do
        expect(bin[5]).to be_nil
      end

      it "has a nil last values" do
        expect(bin.last).to be_nil
      end

      it "pushes items" do
        expect(item1.state).to receive(:moveTo).with(5)
        bin.push(item1)
        expect(bin.size).to eq(1)
        expect(bin[0]).to be(item1)
        expect(bin.last).to be(item1)
      end

      it "inserts items at position 0" do
        expect(item1.state).to receive(:moveTo).with(5)
        bin.insert(0, item1)
        expect(bin[0]).to be(item1)
        expect(bin.last).to be(item1)
      end

      it "inserts it even with wrong position" do
        expect(item1.state).to receive(:moveTo).with(5)
        bin.insert(10, item1)
        expect(bin[0]).to be(item1)
        expect(bin.last).to be(item1)
      end

      it "does not try to move items that aren't there" do
        bin.moveBeforeItem(item1, item2)
        expect(bin.length).to eq(0)
      end

      it "will insertBefore nothing" do
        expect(item1.state).to receive(:moveTo).with(5)
        bin.insertBefore(item1) do
          true
        end
        expect(bin[0]).to be(item1)
        expect(bin.last).to be(item1)
      end

      it "does not delete nonexistant items" do
        bin.delete(item1)
        expect(bin.length).to eq(0)
      end

      it "does nothing on each" do
        bin.each do
          expect(true).to be_false
        end
      end

      it "does nothing on reverse_each" do
        bin.each do
          expect(true).to be_false
        end
      end

      it "always returns true from all?" do
        expect(bin.all? { true }).to be_true
        expect(bin.all? { false }).to be_true
      end

      it "sorts nothing" do
        expect(bin.sort!.size).to eq(0)
      end

      it "returns empty array from find_all" do
        expect(bin.find_all { true }).to eq([])
      end

      it "can assign contents" do
        bin.contents = [item1, item2]
        expect(bin.length).to eq(2)
        expect(bin[0]).to be(item1)
        expect(bin[1]).to be(item2)
      end

      it "knows when it is empty" do
        expect(bin).to be_empty
      end

      it "doesn't find nonexistant items" do
        expect(bin.exists?(item1)).to be_false
      end

      it "doesn't find nonexistant objects" do
        expect(bin.contain?(1)).to be_false
      end

      it "outputs only the bin name from to_s" do
        expect(bin.to_s).to eq("bin-name\n")
      end
    end

    context "bin with contents" do
      subject(:bin) do
        Bin.new("bin-name", 5).tap do |b|
          b.contents = [item1, item2]
        end
      end

      let(:item1) do
        Item.new()
      end

      let(:item2) do
        Item.new()
      end

      let(:item3) do
        Item.new()
      end

      it "has a size/length of 2" do
        expect(bin.length).to eq(2)
        expect(bin.size).to eq(2)
      end

      it "can push an item to the end" do
        expect(item3.state).to receive(:moveTo).with(5)
        bin.push(item3)
        expect(bin.length).to eq(3)
        expect(bin.last).to be(item3)
      end

      it "can index into the bin" do
        bin.push(item3)
        expect(bin[0]).to be(item1)
        expect(bin[1]).to be(item2)
        expect(bin[2]).to be(item3)
        expect(bin[3]).to be_nil
      end

      it "can insert before the first place" do
        expect(item3.state).to receive(:moveTo).with(5)
        bin.insert(0, item3)
        expect(bin[0]).to be(item3)
        expect(bin[1]).to be(item1)
        expect(bin[2]).to be(item2)
        expect(bin[3]).to be_nil
      end

      it "can insert before the second place" do
        expect(item3.state).to receive(:moveTo).with(5)
        bin.insert(1, item3)
        expect(bin[0]).to be(item1)
        expect(bin[1]).to be(item3)
        expect(bin[2]).to be(item2)
        expect(bin[3]).to be_nil
      end

      it "can insert at the end" do
        expect(item3.state).to receive(:moveTo).with(5)
        bin.insert(3, item3)
        expect(bin[0]).to be(item1)
        expect(bin[1]).to be(item2)
        expect(bin[2]).to be(item3)
        expect(bin[3]).to be_nil
      end

      it "can insert before the first item" do
        expect(item3.state).to receive(:moveTo).with(5)
        bin.moveBeforeItem(item3, item1)
        expect(bin[0]).to be(item3)
        expect(bin[1]).to be(item1)
        expect(bin[2]).to be(item2)
        expect(bin[3]).to be_nil
      end

      it "can insert before the second item" do
        expect(item3.state).to receive(:moveTo).with(5)
        bin.moveBeforeItem(item3, item2)
        expect(bin[0]).to be(item1)
        expect(bin[1]).to be(item3)
        expect(bin[2]).to be(item2)
        expect(bin[3]).to be_nil
      end

      it "can move items that are already in the bin" do
        bin.moveBeforeItem(item1, item2)
        expect(bin[0]).to be(item2)
        expect(bin[1]).to be(item1)
        expect(bin[2]).to be_nil
      end

      it "can not insert before items that aren't in the bin" do
        bin.moveBeforeItem(item1, item3)
        expect(bin[0]).to be(item1)
        expect(bin[1]).to be(item2)
        expect(bin[2]).to be_nil
      end
    end
  end
end
