# encoding: utf-8
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
                return @quiz.contents.stats.reviewStatus
            elsif !forgottenSet.empty?
                return " Forgotten Items"
            else
                return "     New Items"
            end
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
        
        # Get an item to quiz
        def getItem
            item = nil

            if !workingSetFull?
                if shouldReview?
                    item = reviewSet.selectItem()
                elsif !forgottenSet.empty?
                    item = forgottenSet.selectItem()
                elsif !newSet.empty?
                    item = getNewItem
                end
            end

            # Usually we get a working item if the above is not true
            item = workingSet.selectItem() if item.nil?

            item.setAllSeen(true) if !item.nil?
            return item
        end

        # Create a problem for the given item at the correct level
        def createProblem(item)
            contents.newProblemFor(item)

            item.itemStats.createProblem
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
            contents.bins[item.bin].stats.correct(item)
            item.itemStats.correct
            item.firstSchedule.correct unless item.firstSchedule.nil?
            if (item.bin != Strategy.workingSetBin) ||
                (item.level >= 3)
                promote(item)
            end
        end

        # Mark the item as having been reviewed incorrectly
        def incorrect(item)
            contents.bins[item.bin].stats.incorrect(item)
            item.allIncorrect
            item.itemStats.incorrect
            demote(item)
        end

        # Mark the item correct, and if it is in the working set, promote
        # it to the review set
        def learn(item)
            correct(item)
            if item.bin <= Strategy.workingSetBin
                promote(item)
            end
        end
    end
end
