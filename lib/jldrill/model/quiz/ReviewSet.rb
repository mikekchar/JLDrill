# encoding: utf-8
require 'jldrill/model/quiz/QuizSet'

module JLDrill

    # Where all the items are stored
    class ReviewSet < QuizSet
        def initialize(quiz, number)
            super(quiz, "Review", number)
            addAlias("Excellent")
        end

        # Put the review set in the correct order according to
        # what percentage of its potential schedule it has waited
        def reschedule
            self.sort! do |x,y|
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
        
        # If an item gets promoted for some reason, it should stay in the review set
        def promotionBin
            return @number
        end
        
        # Some legacy files had kanji problems scheduled, but no
        # kanji data.  This removes those schedules
        def removeInvalidKanjiProblems
            self.each do |x|
                x.removeInvalidKanjiProblems
            end
        end

    end
end
