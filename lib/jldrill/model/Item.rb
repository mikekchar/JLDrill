# encoding: utf-8
require 'jldrill/model/ItemStatus'

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
    # Item also holds position information of the item in the drill
    #    * position is the original ordinal position of the item in the quiz
    #      A position of -1 means the position hasn't been assigned yet
    #    * bin the number of the bin it is in
    #
    # Items stored here must implement the following:
    #    o to_s() -- returns a string representation of the object
    #    o create() -- accepts a string and creates the object
    class Item

        POSITION_RE = /^Position: (.*)/

        attr_reader :itemType, :contents, :position, :bin, :status,
                    :hash, :quiz
        attr_writer :position, :bin, :quiz

        def initialize(item=nil)
            @quiz = nil
            if item.nil?
                @itemType = nil
                @contents = ""
                @hash = "".hash
            else
                @itemType = item.class
                @contents = item.to_s
                @hash = item.hash
            end
            @position = -1
            @bin = 0
            @status = ItemStatus.new(self)
            @cache = nil
        end

        # Create an item using the save string
        def Item.create(string)
            item = Item.new
            item.parse(string)
            return item
        end

        def parsePart(part)
            parsed = true

            case part
            when POSITION_RE 
                @position = $1.to_i
            else # Not something we understand
                parsed = false
            end

            return parsed
        end

        # Parse a whole line which includes status information
        def parseLine(line)
            line.split("/").each do |part|
                if !parsePart(part)
                    @status.parse(part)
                end
            end
        end

        # Set the value of the item by parsing the string
        def parse(string)
            @itemType = JLDrill::Vocabulary
            @contents = string
            parseLine(@contents)
            @hash = self.to_o.hash
        end

        # Create a copy of this item
        def clone
            item = Item.new
            item.assign(self)
            return item
        end

        # Assign the contents of item to this item
        def assign(item)
            setType(item.itemType)
            setContents(item.contents)
            @position = item.position
            @bin = item.bin
            @status.assign(item.status)
            @hash = item.hash
            @cache = nil
        end

        # Set the type of the item
        def setType(aType)
            @itemType = aType
        end

        # set the ItemStatus
        def setStatus(status)
            parseLine(status.to_s)
        end

        # set the contents of the item
        def setContents(contents)
            @contents = contents
            @hash = to_o.hash
        end

        # Return the save format of the item
        def to_s
            retVal = to_o.to_s
            retVal += "/Position: #{@position}"
            retVal += @status.to_s 
            retVal += "/\n"
            return retVal
        end

        # Create the object in the item and return it
        def to_o
            if !@contents.empty?
                if @cache.nil?
                    @cache = @itemType.create(@contents)
                end
            else
                @cache = nil
            end
            return @cache
        end

        # Returns true if the items contain the same object.
        # Note: Does *not* compare the status
        def eql?(item)
            if item.hash == @hash
                self.to_o.eql?(item.to_o)
            else
                false
            end
        end

        def infoStatus
            return "     "
        end

        # Returns true if the item contains the object.
        def contain?(object)
            if object.hash == @hash
                self.to_o.eql?(object)
            else
                false
            end
        end
    end
end
