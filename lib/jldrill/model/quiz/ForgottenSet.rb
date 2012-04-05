# encoding: utf-8
require 'jldrill/model/quiz/QuizSet'

module JLDrill

    # Where all the items are stored
    class ForgottenSet < QuizSet
        attr_reader :stats

        def initialize(quiz, number)
            super(quiz, "Forgotten", number)
            @stats = Statistics.new(quiz, number)
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
            # We need to make sure the items are in the right order
            reschedule
            if !empty? && (options.forgettingThresh != 0.0)
                i = length - 1
                while (i >= 0) && @contents[i].reviewRateUnderThreshold()
                    retVal.push(@contents[i])
                    i -= 1
                end
            end
            return retVal
        end
        
        # If an item gets promoted for some reason, it should go the review set
        def promotionBin
            return @number - 1
        end
        
        # Demoted items should go to the working bin
        def promotionBin
            return @number - 2
        end
    end
end

