# encoding: utf-8
require 'jldrill/model/quiz/Statistics'
require 'jldrill/model/problems/ProblemFactory'

module JLDrill

    # Strategy for choosing, promoting and demoting items in
    # the quiz.
    class Strategy
        attr_reader :quiz
    
        def initialize(quiz)
            @quiz = quiz
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
                retVal = "     #{reviewStats.recentAccuracy}%"
                if reviewStats.inTargetZone?
                    retVal += " - #{(10 - reviewStats.timesInTargetZone)}"
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
            workingSet.length
        end
        
        def workingSetFull?
             workingSet.full?
        end

        def workingSet
            return contents.bins[Strategy.workingSetBin]
        end
        
        def reviewSet
            @quiz.contents.bins[Strategy.reviewSetBin]
        end

        def reviewStats
            reviewSet.stats
        end
        
        # Returns the number of items in the review set
        def reviewSetSize
            reviewSet.length
        end

        def forgottenSet
            @quiz.contents.bins[Strategy.forgottenSetBin]
        end

        def forgottenStats
            forgottenSet.stats
        end
        
        def forgottenSetSize
            forgottenSet.length
        end

        # If the user increases the forgetting threshold,
        # some items need to be returned from the forgotten set
        # to the review set
        def rememberItems
            items = forgottenSet.rememberedItems()
            items.each do |item|
                contents.moveToBin(item, Strategy.reviewSetBin)
            end
        end

        # If the user decreases the forgetting threshold,
        # some items need to be moved from the review set to the
        # forgotten set
        def forgetItems
            items = reviewSet.forgottenItems()
            items.each do |item|
                contents.moveToBin(item, Strategy.forgottenSetBin)
            end
        end

        # Sort the items according to their schedule
        def reschedule
            reviewSet.removeInvalidKanjiProblems
            forgetItems
            rememberItems
            reviewSet.reschedule
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
            else
                return reviewSet.shouldReview?
            end
        end

        # Get an item from the New Set
        # Note: It promotes that item to the working set in the process
        def getNewItem
            item = newSet.selectItem()
            if !item.nil?
                promote(item)
            end
            return item
        end
        
        # Get an item from the Working Set
        def getWorkingItem
            return workingSet.selectItem()
        end

        # Get an item from the Review Set
        def getReviewItem
            return reviewSet.selectItem()
        end

        def getForgottenItem
            return forgottenSet.selectItem()
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

            item.setAllSeen(true)
            return item
        end

        # Create a problem for the given item at the correct level
        def createProblem(item)
            item.itemStats.createProblem
            reviewStats.startTimer(item.bin == Strategy.reviewSetBin)
            forgottenStats.startTimer(item.bin == Strategy.forgottenSetBin)
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
                        reviewStats.learned += 1
                        forgottenStats.learned += 1
                        workingSet.promoteItem(item)
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
            reviewStats.correct(item)
            forgottenStats.correct(item)
            item.itemStats.correct
            item.firstSchedule.correct unless item.firstSchedule.nil?
            if (item.bin != Strategy.workingSetBin) ||
                (item.level >= 3)
                promote(item)
            end
        end

        # Mark the item as having been reviewed incorrectly
        def incorrect(item)
            reviewStats.incorrect(item)
            forgottenStats.incorrect(item)
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
