# encoding: utf-8
require 'jldrill/model/quiz/QuizSet'

module JLDrill

    # Where all the items are stored
    class ForgottenSet < QuizSet

        def initialize(quiz, number)
            super(quiz, "Forgotten", number)
        end

        # Put the forgotten set in the correct order according
        # to what percentage of its potential schedule it has
        # waited
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
        
        # Returns an array of all the items that should be remembered
        # I.e., If the forgetting threshold has increased, item need
        # to be moved to the working set.
        # Note: Assumes the set has been rescheduled recently
        def rememberedItems
            retVal = []
            if !empty? && (options.forgettingThresh != 0.0)
                retVal = @contents.partition do |item|
                    item.reviewRateUnderThreshold()
                end[0]
            end
            return retVal
        end
        
        # If the user increases the forgetting threshold,
        # some items need to be returned from the forgotten set
        # to the review set
        def rememberItems
            rememberedItems().each do |item|
                @quiz.contents.moveToReviewSet(item)
            end
        end

        def correct(item)
            super(item)
            item.itemStats.consecutive += 1
            # Move the item to the back of the set
            @quiz.contents.moveToReviewSet(item)
        end

        def incorrect(item)
            super(item)
        end

        def learn(item)
            # You can't learn from the review set. Do nothing
        end

        def promote(item)
            # You can't promote from the review set.  Do nothing
        end
    end
end

