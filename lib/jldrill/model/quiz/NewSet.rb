# encoding: utf-8
require 'jldrill/model/Bin'
require 'jldrill/model/quiz/QuizItem'

module JLDrill

    # Where all the items are stored
    class NewSet < Bin
        def initialize(quiz, number)
            super("New", number)
            addAlias("Unseen")
            @quiz = quiz
        end

        def options
            @quiz.options
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
            return self[index]
        end

        # Do what is necessary to an item for promotion from this bin
        def promoteItem(item)
            item.setScores(0)
            if options.interleavedWorkingSet
                item.scheduleAll
            end
        end

        # Items from the new set should be promoted to the next bin
        def promotionBin
            return @number + 1
        end

        # Items from the new set should stay in the new set if demoted for some reason
        def demotionBin
            return @number
        end
    end
end

