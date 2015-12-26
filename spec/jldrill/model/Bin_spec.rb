# encoding: utf-8
require 'jldrill/model/Bin'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/Quiz'

module JLDrill

  describe Bin do
    describe "Names" do
      it "should have a name and number" do
        bin = Bin.new("bin-name", 5)
        expect(bin.number).to eq(5)
        expect(bin.isCalled?("bin-name")).to be true
        expect(bin.isCalled?("Frank")).to be false
      end

      it "has a variety of aliases" do
        bin = Bin.new("bin-name", 5)
        bin.addAliases(["Tom", "Dick", "Harry"])
        expect(bin.isCalled?("bin-name")).to be true
        expect(bin.isCalled?("Tom")).to be true
        expect(bin.isCalled?("Dick")).to be true
        expect(bin.isCalled?("Harry")).to be true
        expect(bin.isCalled?("Frank")).to be false
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

      it "does not try to move items that aren't there" do
        bin.moveBeforeItem(item1, item2)
        expect(bin.length).to eq(0)
      end

      it "doesn't find nonexistant items" do
        expect(bin.exists?(item1)).to be false
      end

      it "doesn't find nonexistant objects" do
        expect(bin.contain?(1)).to be false
      end

      it "outputs only the bin name from to_s" do
        expect(bin.to_s).to eq("bin-name\n")
      end
    end

    context "bin with contents" do
      subject(:bin) do
        Bin.new("bin-name", 5).tap do |b|
          b.push(item1)
          b.push(item2)
        end
      end

      let(:item1) do
        Item.new("item1")
      end

      let(:item2) do
        Item.new("item2")
      end

      let(:item3) do
        Item.new("item3")
      end

      it "can push an item to the end" do
        expect(item3.state).to receive(:moveTo).with(5)
        bin.push(item3)
        expect(bin.length).to eq(3)
        expect(bin.last).to be(item3)
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

      it "finds items items" do
        expect(bin.exists?(item2)).to be true
      end

      it "doesn't find nonexistant items" do
        expect(bin.exists?(item3)).to be false
      end

      it "finds objects" do
        expect(bin.contain?("item2")).to be true
      end

      it "doesn't find nonexistant objects" do
        expect(bin.contain?("item3")).to be false
      end

      it "outputs the bin name and all of the items from t_s" do
        expect(bin.to_s).to eq("bin-name\nitem1/Position: -1/\nitem2/Position: -1/\n")
      end
    end
  end
end
