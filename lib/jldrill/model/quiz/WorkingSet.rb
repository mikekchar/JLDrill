# encoding: utf-8
require 'jldrill/model/quiz/QuizSet'

module JLDrill

    # Container for items that are being actively learned
    class WorkingSet < QuizSet
        def initialize(quiz, number)
            super(quiz, "Working", number)
            addAliases(["Poor", "Fair", "Good"])
        end

        def full?
            length() >= options.introThresh
        end

        # Select an item from the new set (probably for promotion)
        def selectItem
            selectRandomUnseenItem
        end

        def correct(item)
            super(item)
            if item.state.level >= 3
                promote(item)
            end
        end

        def learn(item)
            super(item)
            promote(item)
        end

        # Do what is necessary to an item for promotion from this bin
        def promote(item)
            super(item)
            item.state.itemStats.consecutive = 1
            item.state.scheduleAll
            @quiz.contents.moveToReviewSet(item)
        end

        def demote(item)
            # The item is already in the working set.  Do nothing.
        end
    end
end


