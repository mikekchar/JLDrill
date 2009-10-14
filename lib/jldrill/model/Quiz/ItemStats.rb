require 'jldrill/model/Quiz/Strategy'
require 'jldrill/model/Quiz/Timer'

module JLDrill

    # Calculates and stores various statistics for each item in the
    # Spaced Repetition Drill.
    #
    # Consecutive: The number of times this item was remembered correctly
    #              in the review set
    class ItemStats
        CONSECUTIVE_RE = /^Consecutive: (.*)/
        TIMELIMIT_RE = /^TimeLimit: (.*)/

        attr_reader :name, :item, :consecutive, :thinkingTimer, :timeLimit
        attr_writer :item, :consecutive, :thinkingTimer, :timeLimit

        # Create a new ItemStats for this item
        def initialize(item)
            @name = "ItemStats"
            @item = item
            @thinkingTimer = Timer.new
            reset
        end

        # Parse a single part of the ItemStats
        def parse(string)
            parsed = true
            case string
                when CONSECUTIVE_RE
                    @consecutive = $1.to_i
                when TIMELIMIT_RE
                    @timeLimit = $1.to_f
            else
                parsed = false
            end
            parsed
        end

        # Create a clone of the ItemStats and return it
        def clone
            retVal = ItemStats.new(@item)
            retVal.assign(self)
            return retVal
        end

        # Assign this item's stats to be the same as the one passed in
        def assign(itemStats)
            @consecutive = itemStats.consecutive
            @thinkingTimer.assign(itemStats.thinkingTimer)
            @timeLimit = itemStats.timeLimit
        end

        # Reset the statistics for the item
        def reset
            @consecutive = 0
            @thinkingTimer.reset
            @timeLimit = 0.0
        end

        # The item is being used to create a problem
        def createProblem
            @thinkingTimer.reset
            @thinkingTimer.start
            @timeLimit = 0.0
        end

        # The item was not correctly remembered
        def incorrect
            @thinkingTimer.stop
            @consecutive = 0
            @timeLimit = 0.0
        end

        # The item was correctly remembered
        def correct
            @thinkingTimer.stop
            if @item.bin == 4
                @consecutive += 1
                @timeLimit = @thinkingTimer.total
            end
        end

        def exp(number, places)
            retVal = 1
            if places != 0
                retVal = number
                1.upto(places - 1) do
                    retVal = retVal * number
                end
            end
            retVal
        end


        def round(number, places)
            mult = exp(10, places)
            (number * mult).round.to_f / mult
        end

        # Output the ItemStats in save format
        def to_s
            retVal = "/Consecutive: #{@consecutive.to_i}"
            if @timeLimit != 0
                retVal += "/TimeLimit: #{self.round(@timeLimit, 3)}"
            end
            retVal
        end

        def inNewSet?
            @item.bin == Strategy.newSetBin
        end

        def inWorkingSet?
            Strategy.workingSetBins.include?(@item.bin)
        end

        def inReviewSet?
            @item.bin == Strategy.reviewSetBin
        end

    end
end
