# encoding: utf-8

require "jldrill/model/ItemState"

module JLDrill

    # Holds an item for the quiz.  For memory and performance purposes 
    # these items are stored as:
    #
    #    o The class of the underlying object
    #    o A string containing the object
    #
    # The string representation of the object can be obtain through to_s().
    # The object representation of the object can be obtained through to_o().
    #
    # Items stored here must implement the following:
    #    o to_s() -- returns a string representation of the object
    #    o create() -- accepts a string and creates the object
    class Item

        attr_reader :itemType, :contents, :hash, :quiz, :state
        attr_writer :quiz, :state

        def initialize(item=nil)
            @quiz = nil
            if item.nil?
                @itemType = nil
                @contents = ""
                @hash = "".hash
                @cache = nil
            else
                @itemType = item.class
                @contents = item.to_s
                @hash = item.hash
                @cache = item
            end
            @state = ItemState.new(self)
        end

        # Create an item using the save string
        def Item.create(string)
            item = Item.new
            item.parse(string)
            return item
        end

        def parseLine(line)
            line.split("/").each do |part|
                @state.parsePart(part)
            end
        end

        # Set the value of the item by parsing the string
        def parse(string)
            @itemType = JLDrill::Vocabulary
            @contents = string
            parseLine(@contents)
            @hash = self.to_o.hash
        end

        # Assign the contents of item to this item
        def assign(item)
            setType(item.itemType)
            setContents(item.contents)
            @hash = item.hash
            @state = item.state.clone()
            @cache = nil
        end

        # Create a copy of this item
        def clone
            item = Item.new
            item.assign(self)
            return item
        end

        # Set the type of the item
        def setType(aType)
            @itemType = aType
        end

        # set the contents of the item
        def setContents(contents)
            @contents = contents
            @hash = to_o.hash
        end

        def content_to_s
            return to_o.to_s + @state.to_s
        end

        # Return the save format of the item
        def to_s
            return content_to_s + "/\n"
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
        def eql?(item)
            if item.hash == @hash
                self.to_o.eql?(item.to_o)
            else
                false
            end
        end

        def status
            return @state.status
        end

        # Returns true if the item contains the object.
        def contain?(object)
            if object.hash == @hash
                self.to_o.eql?(object)
            else
                false
            end
        end

        # Quiz methods
        def createProblem
            return @state.createProblem
        end

        def incorrect
            return @state.incorrect
        end

        def correct
            return @state.correct
        end

        def learn
            return @state.learn
        end
    end
end
