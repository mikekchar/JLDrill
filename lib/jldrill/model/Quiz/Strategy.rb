require 'jldrill/model/Quiz/Statistics'

module JLDrill

    # Strategy for a quiz
    class Strategy
        attr_reader :stats, :last
        attr_writer :last
    
        def initialize(quiz)
            @quiz = quiz
            @stats = Statistics.new
            @last = nil
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

        # Returns the bin number of the new set
        def newSetBin
            0
        end
        
        # Returns true if there are no items in the new set
        def newSetEmpty?
            contents.bins[0].empty?
        end
        
        def workingSetRange
            1..3
        end
        
        # Returns true if there are no items in the working set
        def workingSetEmpty?
            contents.rangeEmpty?(1..3)
        end
        
        # Returns the number of items in the working set
        def workingSetSize
            contents.bins[1].length + contents.bins[2].length + contents.bins[3].length
        end
        
        # Returns true if the working set is not full
        def workingSetFull?
             workingSetSize >= @quiz.options.introThresh
        end
        
        # returns the bin number of the review set
        def reviewSetBin
            4
        end
        
        # Returns the number of items in the review set
        def reviewSetSize
            @quiz.contents.bins[reviewSetBin].length
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
            if  (newSetEmpty? && workingSetEmpty?) || (@quiz.options.reviewMode)
                return true
            end
            
            !workingSetKnown? && (reviewSetSize >= @quiz.options.introThresh)
        end
        
        def getItemFromBin
            if contents.empty?
                return nil
            end

            if !workingSetFull?
                if shouldReview?
                    return getReviewItem
                elsif !newSetEmpty?
                    return getNewItem
                end
            end
            
            return getWorkingItem
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
        
        def getNewItem
            if @quiz.options.randomOrder
                index = rand(contents.bins[newSetBin].length)
            else
                index = findUnseen(newSetBin)
            end
            if !(index == -1)
                item = contents.bins[newSetBin][index]
                promote(item)
                item
            else
                nil
            end
        end
        
        def getReviewItem
            index = findUnseen(reviewSetBin)
            if !(index == -1)
                contents.bins[reviewSetBin][index]
            else
                nil
            end
        end
        
        def getWorkingItem
            randomUnseen(workingSetRange)
        end
        
        def getItem
            item = getItemFromBin
            if item.nil?
                return nil
            end

            item.status.seen = true
            @last = item 
            return item
        end

        
        def createProblem(item)
            # Drill at random levels in bin 4, but don't drill reading
            if item.status.bin == 4
                level = rand(2) + 1
            else
                # Otherwise drill for the specific bin
                level = item.status.bin - 1
            end
            @stats.startTimer(item.status.bin == 4)
            Problem.create(level, item, @quiz)
        end
        
        # Move the specified item to the specified bin
        def moveToBin(item, bin)
            contents.moveToBin(item, bin)
        end

        def promote(item)
            if !item.nil?
                if (item.status.bin + 1 < contents.bins.length)
                    if (item.status.bin + 1) == 4
                        @stats.learned += 1
                    end 
                    moveToBin(item, item.status.bin + 1)
                    item.status.level = item.status.bin - 1 unless item.status.bin - 1 > 2
                end
            end
        end

        def demote(item)
            if item
                item.status.level = 0
                if (item.status.bin != 0)
                    moveToBin(item, 1)
                else
                	# Demoting bin 0 items is non-sensical, but it should do
	                # something sensible anyway.
                    moveToBin(item, 0)
                end
            end
        end

        def collectStatistics(item, good)
            if(item.status.bin == 4)
                @stats.reviewed += 1
                if(good)
                    @stats.correct(item)
                else
                    @stats.incorrect(item)
                end
            end
        end
  
        def correct
            item = @quiz.currentProblem.item
            collectStatistics(item, true)
            if(!item.nil?)
                item.status.schedule
                item.status.markReviewed
                item.status.score += 1
                if(item.status.score >= @quiz.options.promoteThresh)
                    item.status.score = 0
                    promote(item)
                end
                if item.status.bin == 4
                    item.status.consecutive += 1
                    contents.bins[4].sort! do |x, y|
                        x.status.scheduledTime <=> y.status.scheduledTime
                    end
                end
                @quiz.setNeedsSave(true)
            end
        end

        def incorrect
            item = @quiz.currentProblem.item
            collectStatistics(item, false)
            if(item)
                item.status.unschedule
                item.status.markReviewed
                item.status.score = 0
                item.status.incorrect
                demote(@quiz.currentProblem.item)
                item.status.consecutive = 0
                @quiz.setNeedsSave(true)
            end
        end
    end
end
