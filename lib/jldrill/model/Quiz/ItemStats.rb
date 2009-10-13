require 'jldrill/model/Quiz/Strategy'

module JLDrill

    # Calculates and stores various statistics for each item in the
    # Spaced Repetition Drill.
    #
    # Consecutive: The number of times this item was remembered correctly
    #              in the review set
    class ItemStats
        CONSECUTIVE_RE = /^Consecutive: (.*)/

        attr_reader :name, :item, :consecutive, :thinkingTime
        attr_writer :item, :consecutive, :thinkingTime

        # Create a new ItemStats for this item
        def initialize(item)
            @name = "ItemStats"
            @item = item
            reset
        end

        # Parse a single part of the ItemStats
        def parse(string)
            parsed = true
            case string
                when CONSECUTIVE_RE
                    @consecutive = $1.to_i
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
            @thinkingTime = itemStats.thinkingTime
        end

        # Reset the statistics for the item
        def reset
            @consecutive = 0
            # thinkingTime is not set all the time
            @thinkingTime = nil
        end

        # The item was not correctly remembered
        def incorrect
            @consecutive = 0
        end

        # The item was correctly remembered
        def correct
            if @item.bin == 4
                @consecutive += 1
            end
        end

        # Output the ItemStats in save format
        def to_s
            retVal = "/Consecutive: #{@consecutive.to_i}"
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
