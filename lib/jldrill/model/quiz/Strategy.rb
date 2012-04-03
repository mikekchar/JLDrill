# encoding: utf-8
require 'jldrill/model/quiz/Statistics'
require 'jldrill/model/problems/ProblemFactory'

module JLDrill

    # Strategy for choosing, promoting and demoting items in
    # the quiz.
    class Strategy
        attr_reader :quiz, :reviewStats, :forgottenStats
    
        def initialize(quiz)
            @quiz = quiz
            @reviewStats = Statistics.new(quiz, Strategy.reviewSetBin)
            @forgottenStats = Statistics.new(quiz, Strategy.forgottenSetBin)
        end
        
        def Strategy.newSetBin
            return 0
        end

        def Strategy.workingSetBin
            return 1
        end

        def Strategy.reviewSetBin
            return 2
        end

        def Strategy.forgottenSetBin
            return 3
        end
        
        # Returns a string showing the status of the quiz with this strategy
        def status
            if shouldReview?
                retVal = "     #{@reviewStats.recentAccuracy}%"
                if @reviewStats.inTargetZone?
                    retVal += " - #{(10 - @reviewStats.timesInTargetZone)}"
                end
            elsif !forgottenSet.empty?
                retVal = " Forgotten Items"
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
        
        # Returns the number of items in the working set
        def workingSetSize
            contents.bins[Strategy.workingSetBin].length
        end
        
        # Returns true if the working set is not full
        def workingSetFull?
             workingSetSize >= options.introThresh
        end

        def workingSet
            return contents.bins[Strategy.workingSetBin]
        end
        
        def reviewSet
            @quiz.contents.bins[Strategy.reviewSetBin]
        end

        # Returns the number of items in the review set
        def reviewSetSize
            reviewSet.length
        end

        def forgottenSet
            @quiz.contents.bins[Strategy.forgottenSetBin]
        end

        def forgottenSetSize
            forgottenSet.length
        end

        # Put the review set in the correct order according to
        # what percentage of its potential schedule it has waited
        def rescheduleReviewSet
            reviewSet.sort! do |x,y|
                xSchedule = x.firstSchedule
                ySchedule = y.firstSchedule
                # Schedule should never be nil except in the tests,
                # but just in case
                if !xSchedule.nil?
                    if !ySchedule.nil?
                        xSchedule.reviewLoad <=> ySchedule.reviewLoad
                    else
                        -1
                    end
                else
                    1
                end
            end
        end

        # Put the forgotten set in the correct order according
        # to what percentage of its potential schedule it has
        # waited
        def rescheduleForgottenSet
            forgottenSet.sort! do |x,y|
                # Schedule should never be nil except in the tests,
                # but just in case
                if !x.schedule.nil?
                    if !y.schedule.nil?
                        x.schedule.reviewLoad <=> y.schedule.reviewLoad
                    else
                        -1
                    end
                else
                    1
                end
            end
        end

        # returns true if the review rate of an item is below
        # the forgetting threshold in the options
        def reviewRateUnderThreshold(item)
            retVal = false
            # The schedule should only be nil in the tests, but if it
            # is, this will return false
            if !item.firstSchedule.nil?
                retVal = item.firstSchedule.reviewRate < 
                options.forgettingThresh.to_f
            end
            return retVal
        end

        # If the user changes increases the forgetting threshold,
        # some items need to be returned from the forgotten set
        # to the review set
        def unforgetItems
            while ((!forgottenSet.empty?) &&
                  ((options.forgettingThresh == 0.0) ||
                   reviewRateUnderThreshold(forgottenSet.last)))
                contents.moveToBin(forgottenSet.last, Strategy.reviewSetBin)
            end
        end

        # If the user decreases the forgetting threshold,
        # some items need to be moved from the review set to the
        # forgotten set
        def forgetItems
            while ((options.forgettingThresh != 0.0) &&
                   (!reviewSet.empty?) && 
                   !reviewRateUnderThreshold(reviewSet[0]))
                contents.moveToBin(reviewSet[0], Strategy.forgottenSetBin)
            end
        end

        # Some legacy files had kanji problems scheduled, but no
        # kanji data.  This removes those schedules
        def removeInvalidKanjiProblems
            reviewSet.each do |x|
                x.removeInvalidKanjiProblems
            end
        end

        # Sort the items according to their schedule
        def reschedule
            removeInvalidKanjiProblems
            rescheduleReviewSet
            forgetItems
            rescheduleForgottenSet
            unforgetItems
            rescheduleReviewSet
        end
        
        # Returns true if the review set has been
        # reviewed enough that it is considered to be
        # known.  This happens when we have reviewed
        # ten items while in the target zone.
        # The target zone occurs when in the last 10
        # items, we have a 90% success rate or when
        # we have a 90% confidence that the the items
        # have a 90% chance of success.
        def reviewSetKnown?
            !(10 - @reviewStats.timesInTargetZone > 0)        
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
            if  (newSet.empty? && workingSet.empty?) || (options.reviewMode)
                return true
            end
            
            !reviewSetKnown? && (reviewSetSize >= options.introThresh) && 
                !(allSeen?(reviewSet))
        end

        # Returns true if the item has been seen before.  If the
        # item has no schedule set, then it hasn't been seen before.
        def seen?(item)
            retVal = false
            if !item.firstSchedule.nil?
                retVal = item.firstSchedule.seen
            end
            return retVal
        end

        # Returns the number of unseen items in the bin
        def numUnseen(bin)
            total = 0
            bin.each do |item|
                total += 1 if !seen?(item)
            end
            total
        end
        
        # Returns true if all the items in the bin have been seen
        def allSeen?(bin)
            bin.all? do |item|
                seen?(item)
            end
        end
        
        # Return the index of the first item in the bin that hasn't been
        # seen yet.  Returns -1 if there are no unseen items
        def firstUnseen(bin)
            index = 0
            # find the first one that hasn't been seen yet
            while (index < bin.length) && seen?(bin[index])
                index += 1
            end
            
            if index >= bin.length
                index = -1
            end
            index
        end
        
        # Return the nth unseen item in the bin
        def findNthUnseen(bin, n)
            retVal = nil
            if n < numUnseen(bin)
                i = 0
                0.upto(n) do |m|
                    while seen?(bin[i])
                        i += 1
                    end
                    if m != n
                        i += 1
                    end
                end
                retVal = bin[i]
            end
            retVal
        end

        # Sets the schedule of each item in the bin to unseen
        def setUnseen(bin)
            bin.each do |item|
                if !item.firstSchedule.nil?
                    item.firstSchedule.seen = false
                end
            end
        end
        
        
        # Return the index of the first item in the bin that hasn't been
        # seen yet.  If they have all been seen, reset the bin
        def findUnseenIndex(binNum)
            bin = contents.bins[binNum]
            if bin.empty?
                return -1
            end

            if allSeen?(bin)
                setUnseen(bin)
            end
            firstUnseen(bin)
        end
        
        # Returns a random unseen item.
        # Resets the seen status if all the items are already seen.
        def randomUnseen(bin)
            if allSeen?(contents.bins[bin])
                setUnseen(contents.bins[bin])
            end
            index = rand(numUnseen(contents.bins[bin]))
            item = findNthUnseen(contents.bins[bin], index)
            item
        end
        
        # Get an item from the New Set
        def getNewItem
            item = newSet.selectItem()
            if !item.nil?
                promote(item)
            end
            return item
        end
        
        # Get an item from the Review Set
        def getReviewItem
            reviewSet[0]
        end

        def getForgottenItem
            forgottenSet[0]
        end
        
        # Get an item from the Working Set
        def getWorkingItem
            randomUnseen(Strategy.workingSetBin)
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
                elsif !forgottenSet.empty?
                    item = getForgottenItem
                elsif !newSet.empty?
                    item = getNewItem
                end
            end

            # Usually we get a working item if the above is not true
            item = getWorkingItem if item.nil?

            item.allSeen(true)
            return item
        end

        # Create a problem for the given item at the correct level
        def createProblem(item)
            item.itemStats.createProblem
            @reviewStats.startTimer(item.bin == Strategy.reviewSetBin)
            @forgottenStats.startTimer(item.bin == Strategy.forgottenSetBin)
            return item.problem
        end

        # Promote the item to the next level/bin
        def promote(item)
            if !item.nil?
                if item.bin == Strategy.newSetBin
                    contents.moveToBin(item, newSet.promotionBin())
                    newSet.promoteItem(item)
                else 
                    if item.bin == Strategy.workingSetBin
                        # Newly promoted items
                        item.itemStats.consecutive = 1
                        @reviewStats.learned += 1
                        @forgottenStats.learned += 1
                        item.scheduleAll
                    end
                    # Put the item at the back of the reviewSet
                    contents.moveToBin(item, Strategy.reviewSetBin)
                end
            end
        end

        # Demote the item
        def demote(item)
            if !item.nil?
                item.demoteAll
                if (item.bin != Strategy.newSetBin)
                    contents.moveToBin(item, Strategy.workingSetBin)
                else
                	# Demoting New Set items is non-sensical, but it should do
	                # something sensible anyway.
                    contents.moveToBin(item, Strategy.newSetBin)
                end
            end
        end

        # Mark the item as having been reviewed correctly
        def correct(item)
            @reviewStats.correct(item)
            @forgottenStats.correct(item)
            item.itemStats.correct
            item.firstSchedule.correct unless item.firstSchedule.nil?
            if (item.bin != Strategy.workingSetBin) ||
                (item.level >= 3)
                promote(item)
            end
        end

        # Mark the item as having been reviewed incorrectly
        def incorrect(item)
            @reviewStats.incorrect(item)
            @forgottenStats.incorrect(item)
            item.allIncorrect
            item.itemStats.incorrect
            demote(item)
        end

        # Promote the item from the working set into the review
        # set without any further training.  If it is already
        # in the review set, simply mark it correct.
        def learn(item)
            if item.bin <= Strategy.workingSetBin
                contents.moveToBin(item, Strategy.reviewSetBin)
            end
            correct(item)
        end
    end
end
