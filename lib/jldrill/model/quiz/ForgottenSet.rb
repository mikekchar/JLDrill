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
                # Schedule should never be nil except in the tests,
                # but just in case
                if !x.schedule.nil?
                    if !y.schedule.nil?
                        x.schedule.reviewLoad <=> y.schedule.reviewLoad
                    else
                        -1
                    end
                else
                    1
                end
            end
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

