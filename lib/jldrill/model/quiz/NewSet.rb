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

        # Do what is necessary to an item for promotion from this bin
        def promoteItem(item)
            item.setScores(0)
            if options.interleavedWorkingSet
                item.scheduleAll
            end
        end

        # Items from the new set should stay in the new set if demoted for some reason
        def demotionBin
            return @number
        end
    end
end

