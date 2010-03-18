require 'jldrill/model/items/ItemFactory'
require 'jldrill/model/ItemStatus'
require 'jldrill/model/ProblemStatus'
require 'jldrill/model/Quiz/ItemStats'

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
    #    * bin is the number of the bin
    #
    # Items stored here must implement the following:
    #    o to_s() -- returns a string representation of the object
    #    o create() -- accepts a string and creates the object
    class Item

        POSITION_RE = /^Position: (.*)/

        attr_reader :itemType, :contents, :position, :bin, :status,
                    :hash, :container, :quiz
        attr_writer :position, :bin, :container, :quiz

        def initialize(item=nil)
            @quiz = nil
            if item.nil?
                @itemType = nil
                @contents = ""
                @hash = "".hash
            else
                @itemType = item.itemType
                @contents = item.to_s
                @hash = item.hash
            end
            @position = -1
            @bin = 0
            @container = nil
            @status = ItemStatus.new(self)
            @status.add(ProblemStatus.new(self))
            @status.add(ItemStats.new(self))
        end

        # Create an item using the save string
        # Note: We are passing bin to this method, since we no
        # longer read it in.  Due to legacy issues, the item status
        # needs to know what bin it is in when parsing.
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
            @itemType = ItemFactory::find("Vocabulary")
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

        # Return the schedule for the Spaced Repetition Drill
        def schedule
            problemStatus = @status.select("ProblemStatus")
            return problemStatus.firstSchedule
        end

        def problem
            problemStatus = @status.select("ProblemStatus")
            return problemStatus.firstProblem
        end

        def itemStats
            return @status.select("ItemStats")
        end

        # Assign the contents of item to this item
        def assign(item)
            setType(item.itemType)
            setContents(item.contents)
            @position = item.position
            @bin = item.bin
            @status.assign(item.status)
            @hash = item.hash
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

        # swap the positions between two items
        def swapWith(item)
            temp = @position
            @position = item.position
            item.position = temp
        end

        def insertBefore(item)
            target = item.position
            # This is clearly slow. It can be made slightly
            # faster by only iterating over the relevant
            # items, but I don't know if it's worth the effort
            # since the majority of the cost is in creating the
            # sorted array in the first place.
            @container.eachByPosition do |i|
                if (i.position >= target) &&
                        (i.position < @position)
                    i.position += 1
                end
            end
            @position = target
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
                item = @itemType.create(@contents)
            else
                item = nil
            end
            return item
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

        # Returns true if the item contains the object.
        def contain?(object)
            if object.hash == @hash
                self.to_o.eql?(object)
            else
                false
            end
        end

        # Indicate to the quiz that the problem has been modified
        # This will be called by the problem itself whenever it
        # has been modified.
        def problemModified(problem)
            if !@quiz.nil?
                @quiz.problemModified(problem)
            end
        end
    end
end
