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

        # Do what is necessary to an item for promotion from this bin
        def promoteItem(item)
            item.itemStats.consecutive = 1
            item.scheduleAll
        end
    end
end


