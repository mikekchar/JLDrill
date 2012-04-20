# encoding: utf-8

require 'jldrill/model/problems/ProblemFactory'

module JLDrill

    # Represents the state of the item in the Quiz.  This is an abstract
    # class.  The concrete versions might store statistics, schedules
    # and the like.
    class ItemState

        POSITION_RE = /^Position: (.*)/

        attr_reader :item, :bin, :position

        def initialize(item)
            @item = item
            @bin = 0
            @position = -1
        end

        # Assign the contents of itemState to this itemState
        def assign(itemState)
            @item = itemState.item
            @bin = itemState.bin
            @potions = itemState.position
        end

        # Make a new ItemState
        def clone()
            retVal = ItemState.new(@item)
            retVal.assign(self)
            return retVal
        end

        # Parses part of an item (the bits between slashes in the save file)
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

        # The following are actions that change the state of an item.
        # The caller should clone the state from the item, modify it
        # using one of these methods and then set the state of the item
        # using the new state.
        
        # The current problem for the item was drilled and was incorrect
        def incorrect
        end

        # The current problem for the item was drilled and was correct
        def correct
        end

        # The item was promoted at the user's request
        def learn
        end

        # Set the oridinal position of the item in the overall quiz.
        def reposition(pos)
            @position = pos
        end

        # Indicate that the item is now in the idicated bin
        def moveTo(bin)
            @bin = bin
        end

        # The following are actions to query the state of the of the
        # item.  These methods do not change the state of the item and
        # thus there is no need to create a new state.
        
        # Returns user feedback about the state of the item.
        def status
            return "     "
        end

        # Creates an appropriate problem for the item based on it's
        # current state.  For items that are not in a quiz, just
        # create a reading problem.
        def currentProblem
            return ProblemFactory.createKindOf("ReadingProblem", @item)
        end

        # The timeLimit is the number of seconds the user has to guess
        # the answer before the problem expires.  Items that are not
        # in a quiz have no time limit.
        def timeLimit
            return 0.0
        end

        # Returns a string containing the save file representation of 
        # this state
        def to_s
            return "/Position: #{@position}"
        end
    end
end

