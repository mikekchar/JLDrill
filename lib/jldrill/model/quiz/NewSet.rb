# encoding: utf-8
require 'jldrill/model/quiz/QuizSet'

module JLDrill

    # Where all the items are stored
    class NewSet < QuizSet
        def initialize(quiz, number)
            super(quiz, "New", number)
            addAlias("Unseen")
        end

        # Select an item from the new set (probably for promotion)
        def selectItem
            if empty?
                return nil
            end
            if options.randomOrder
                index = rand(length())
            else
                index = 0
            end
            return @contents[index]
        end

        def correct(item)
            super(item)
        end

        def incorrect(item)
            super(item)
        end

        def learn(item)
            super(item)
            @stats.promote(item)
            item.setScores(options.promoteThresh)
            @quiz.contents.moveToReviewSet(item)
        end

        # Do what is necessary to an item for promotion from this bin
        def promote(item)
            super(item)
            item.setScores(0)
            @quiz.contents.moveToWorkingSet(item)
            # We have to schedule after we move the item because new set
            # items don't have any schedules
            if options.interleavedWorkingSet
                item.scheduleAll
            end
        end

        def demote(item)
            # You can't demote from the new set.  No nothing.
        end
    end
end

