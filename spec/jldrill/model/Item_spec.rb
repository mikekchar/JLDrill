# encoding: utf-8
require 'jldrill/model/Item'
require 'jldrill/model/items/Vocabulary'

module JLDrill

    describe Item do

        it "should be able to swap the positions of items" do
            item1 = Item.create("/This is item one/Position: 1/")
            item2 = Item.create("/This is item two/Position: 2/")
            item1.position.should be(1)
            item2.position.should be(2)
            item1.swapWith(item2)
            item1.position.should be(2)
            item2.position.should be(1)
        end

    end
end
