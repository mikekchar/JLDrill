require 'jldrill/model/Quiz/Statistics'

module JLDrill

    # Strategy for choosing, promoting and demoting items in
    # the quiz.
    class Strategy
        attr_reader :stats
    
        def initialize(quiz)
            @quiz = quiz
            @stats = Statistics.new(quiz)
        end
        
        def Strategy.newSetBin
            return 0
        end

        def Strategy.workingSetBins
            return 1..3
        end

        def Strategy.reviewSetBin
            return 4
        end
        
        # Returns a string showing the status of the quiz with this strategy
        def status
            if shouldReview?
                retVal = "     #{@stats.recentAccuracy}%"
                if @stats.inTargetZone?
                    retVal += " - #{(10 - @stats.timesInTargetZone)}"
                end
            else
                retVal = "     New Items"
            end
            retVal
        end

        # Returns the contents for the quiz
        def contents
            @quiz.contents
        end

        # Returns the options for the quiz
        def options
            @quiz.options
        end

        def newSet
            @quiz.contents.bins[Strategy.newSetBin]
        end
        
        def workingSetEmpty?
            contents.rangeEmpty?(Strategy.workingSetBins)
        end
        
        # Returns the number of items in the working set
        def workingSetSize
            contents.bins[1].length + contents.bins[2].length + contents.bins[3].length
        end
        
        # Returns true if the working set is not full
        def workingSetFull?
             workingSetSize >= options.introThresh
        end
        
        def reviewSet
            @quiz.contents.bins[Strategy.reviewSetBin]
        end

        # Returns the number of items in the review set
        def reviewSetSize
            reviewSet.length
        end
        
        # Returns true is the working set has been
        # reviewed enough that it is considered to be
        # known.  This happens when we have reviewed
        # ten items while in the target zone.
        # The target zone occurs when in the last 10
        # items, we have a 90% success rate or when
        # we have a 90% confidence that the the items
        # have a 90% chance of success.
        def workingSetKnown?
            !(10 - @stats.timesInTargetZone > 0)        
        end
        
        # Returns true if at least one working set full of
        # items have been promoted to the review set, and
        # the review set is not known to the required
        # level.
        # Note: if the new set and the working set are
        # both empty, this will always return true.
        def shouldReview?
            # if we only have review set items, or we are in review mode
            # then return true
            if  (newSet.empty? && workingSetEmpty?) || (options.reviewMode)
                return true
            end
            
            !workingSetKnown? && (reviewSetSize >= options.introThresh) &&
                !contents.bins[4].allSeen?
        end
        
        # Return the index of the first item in the bin that hasn't been
        # seen yet.  If they have all been seen, reset the bin
        def findUnseen(binNum)
            bin = contents.bins[binNum]
            if bin.empty?
                return -1
            end

            if bin.allSeen?
                bin.setUnseen
            end
            bin.firstUnseen            
        end
        
        # Returns a random unseen item.  Return nil if the range is empty.
        # Resets the seen status if all the items are already seen.
        def randomUnseen(range)
            if contents.rangeEmpty?(range)
                return nil
            end
            if contents.rangeAllSeen?(range)
                range.to_a.each do |bin|
                    contents.bins[bin].setUnseen
                end
            end
            index = rand(contents.numUnseen(range))
            item = contents.findUnseen(index, range)
            item
        end
        
        # Get an item from the New Set
        def getNewItem
            if options.randomOrder
                index = rand(newSet.length)
            else
                index = findUnseen(Strategy.newSetBin)
            end
            if !(index == -1)
                item = newSet[index]
                # Resetting the schedule to make up for the consequences
                # of an old bug where reset drills weren't reset properly.
                item.schedule.reset
                promote(item)
                item
            else
                nil
            end
        end
        
        # Get an item from the Review Set
        def getReviewItem
            index = findUnseen(Strategy.reviewSetBin)
            if !(index == -1)
                reviewSet[index]
            else
                nil
            end
        end
        
        # Get an item from the Working Set
        def getWorkingItem
            randomUnseen(Strategy.workingSetBins)
        end

        # Get an item to quiz
        def getItem
            item = nil
            if contents.empty?
                return nil
            end

            if !workingSetFull?
                if shouldReview?
                    item = getReviewItem
                elsif !newSet.empty?
                    item = getNewItem
                end
            end

            # Usually we get a working item if the above is not true
            item = getWorkingItem if item.nil?

            item.schedule.seen = true
            return item
        end

        # Create a problem for the given item at the correct level
        def createProblem(item)
            item.itemStats.createProblem
            # Drill at random levels in bin 4, but don't drill reading
            if item.bin == 4
                level = rand(2) + 1
            else
                # Otherwise drill for the specific bin
                level = item.bin - 1
            end
            @stats.startTimer(item.bin == 4)
            Problem.create(level, item, @quiz)
        end

        # Promote the item to the next level/bin
        def promote(item)
            if !item.nil?
                if item.bin < 3
                    item.schedule.level = item.bin
                    contents.moveToBin(item, item.bin + 1)
                else
                    if item.bin == 3
                        # Newly promoted items
                        item.itemStats.consecutive = 1
                        @stats.learned += 1
                    end
                    # Insert the item into the correct place according to schedule
                    contents.bins[item.bin].delete(item)
                    target = item.schedule.getScheduledTime
                    contents.bins[4].insertBefore(item) do |index|
                        contents.bins[4][index].schedule.getScheduledTime > target
                    end
                end
            end
        end

        # Demote the item
        def demote(item)
            if !item.nil?
                item.schedule.level = 0
                if (item.bin != 0)
                    contents.moveToBin(item, 1)
                else
                	# Demoting bin 0 items is non-sensical, but it should do
	                # something sensible anyway.
                    contents.moveToBin(item, 0)
                end
            end
        end

        # Mark the item as having been reviewed correctly
        def correct(item)
            @stats.correct(item)
            item.schedule.correct
            item.itemStats.correct
            if(item.schedule.score >= options.promoteThresh)
                item.schedule.score = 0
                promote(item)
            elsif item.bin == 4
                promote(item)
            end
        end

        # Mark the item as having been reviewed incorrectly
        def incorrect(item)
            @stats.incorrect(item)
            item.schedule.incorrect
            item.itemStats.incorrect
            demote(item)
        end
    end
end
