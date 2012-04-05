# encoding: utf-8
require 'jldrill/model/quiz/QuizSet'

module JLDrill

    # Where all the items are stored
    class ReviewSet < QuizSet
        attr_reader :stats

        def initialize(quiz, number)
            super(quiz, "Review", number)
            addAlias("Excellent")
            @stats = Statistics.new(quiz, number)
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

        # Returns true if the review set has been
        # reviewed enough that it is considered to be
        # known.  This happens when we have reviewed
        # ten items while in the target zone.
        # The target zone occurs when in the last 10
        # items, we have a 90% success rate or when
        # we have a 90% confidence that the the items
        # have a 90% chance of success.
        def known?
            !(10 - @stats.timesInTargetZone > 0)        
        end

        # Returns true if the review set feels that it should be reviewed
        # This happens if the items aren't known to the required level,
        # there are enough items in the set and they haven't all been seen before.
        def shouldReview?
            !known? && (length >= options.introThresh) && !allSeen?
        end

        # Returns an array of all the items that should be forgotten
        def forgottenItems
            retVal = []
            if !empty? && (options.forgettingThresh != 0.0)
                retVal = @contents.partition do |item|
                    !item.reviewRateUnderThreshold()
                end[0]
            end
            return retVal
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
