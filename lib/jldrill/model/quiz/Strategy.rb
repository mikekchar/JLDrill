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
        
        # Returns a string showing the status of the quiz with this strategy
        def status
            if shouldReview?
                return @quiz.contents.stats.reviewStatus
            elsif !contents.forgottenSet.empty?
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

        # If the user increases the forgetting threshold,
        # some items need to be returned from the forgotten set
        # to the review set
        def rememberItems
            items = contents.forgottenSet.rememberedItems()
            items.each do |item|
                contents.moveToReviewSet(item)
            end
        end

        # If the user decreases the forgetting threshold,
        # some items need to be moved from the review set to the
        # forgotten set
        def forgetItems
            items = contents.reviewSet.forgottenItems()
            items.each do |item|
                contents.moveToForgottenSet(item)
            end
        end

        # Sort the items according to their schedule
        def reschedule
            contents.reviewSet.removeInvalidKanjiProblems
            forgetItems
            rememberItems
            contents.reviewSet.reschedule
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
            if  (contents.newSet.empty? && contents.workingSet.empty?) || 
                (options.reviewMode)
                return true
            else
                return contents.reviewSet.shouldReview?
            end
        end

        # Get an item from the New Set
        # Note: It promotes that item to the working set in the process
        def getNewItem
            item = contents.newSet.selectItem()
            if !item.nil?
                promote(item)
            end
            return item
        end
        
        # Get an item to quiz
        def getItem
            item = nil

            if !contents.workingSet.full?
                if shouldReview?
                    item = contents.reviewSet.selectItem()
                elsif !contents.forgottenSet.empty?
                    item = contents.forgottenSet.selectItem()
                elsif !contents.newSet.empty?
                    item = getNewItem
                end
            end

            # Usually we get a working item if the above is not true
            item = contents.workingSet.selectItem() if item.nil?

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
                if item.inNewSet?
                    contents.moveToWorkingSet(item)
                    contents.newSet.promoteItem(item)
                else 
                    if item.inWorkingSet?
                        contents.workingSet.promoteItem(item)
                    end
                    # Put the item at the back of the reviewSet
                    contents.moveToReviewSet(item)
                end
            end
        end

        # Demote the item
        def demote(item)
            if !item.nil?
                item.demoteAll
                if !item.inNewSet?
                    contents.moveToWorkingSet(item)
                else
                	# Demoting New Set items is non-sensical
	                # Do Nothing
                end
            end
        end

        # Mark the item as having been reviewed correctly
        def correct(item)
            contents.bins[item.bin].stats.correct(item)
            item.itemStats.correct
            item.firstSchedule.correct unless item.firstSchedule.nil?
            if !item.inWorkingSet? || (item.level >= 3)
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
            if item.inNewSet? || item.inWorkingSet?
                promote(item)
            end
        end
    end
end
