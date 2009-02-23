require 'jldrill/model/ItemFactory'
require 'jldrill/model/Quiz/ItemStatus'
require 'jldrill/model/Problem'

module JLDrill

    # Holds an item for the quiz.  For memory and performance purposes 
    # these items are stored as:
    #
    #    o The class of the underlying object
    #    o A string containing the object
    #    o The ItemStatus of the object
    #
    # The string representation of the object can be obtain through to_s().
    # The object representation of the object can be obtained through to_o().
    #
    # Items stored here must implement the following:
    #    o to_s() -- returns a string representation of the object
    #    o create() -- accepts a string and creates the object
    class Item
        attr_reader :status, :itemType

        def initialize(item=nil)
            if item.nil?
                @itemType = nil
                @contents = ""
            else
                @itemType = item.itemType
                @contents = item.to_s
            end
            @status = ItemStatus.new
        end

        # Create an item using the save string
        def Item.create(string)
            item = Item.new
            item.parse(string)
            return item
        end

        # Set the value of the item by parsing the string
        def parse(string)
            @itemType = ItemFactory::find("Vocabulary")
            @contents = string
            @status.parseLine(@contents)
        end

        # Create a copy of this item
        def clone
            item = Item.new
            item.setType(@itemType)
            item.setContents(@contents)
            item.setStatus(@status.to_s)
            return item
        end

        # Set the type of the item
        def setType(aType)
            @itemType = aType
        end

        # set the ItemStatus
        def setStatus(status)
            @status.parseLine(status.to_s)
        end

        # set the contents of the item
        def setContents(contents)
            @contents = contents
        end

        # Return the save format of the item
        def to_s
            return to_o.to_s + @status.to_s + "/\n"
        end

        # Create the object in the item and return it
        def to_o
            if !@contents.empty?
                item = @itemType.create(@contents)
            else
                item = nil
            end
            return item
        end

        # Returns true if the items contain the same object.
        # Note: Does *not* compare the status
        def eql?(item)
            self.to_o.eql?(item.to_o)
        end

        # Returns true if the item contains the object.
        def contain?(object)
            self.to_o.eql?(object)
        end
    end
end
