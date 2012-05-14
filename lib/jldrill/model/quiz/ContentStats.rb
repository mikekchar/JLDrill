# encoding: utf-8

module JLDrill

    # Statistics for the overall contents in the quiz
    class ContentStats
        def initialize(contents)
            @contents = contents
        end

        # Returns the accuracy of items reviewed in the review set
        def reviewAccuracy
            return @contents.reviewSet.stats.accuracy
        end

        def forgottenAccuracy
            return @contents.forgottenSet.stats.accuracy
        end

        def forgottenSetRate
            return @contents.forgottenSet.stats.currentReviewRate
        end

        def reviewSetRate
            return @contents.reviewSet.stats.currentReviewRate
        end

        def averageForgottenSetRate
            return @contents.forgottenSet.stats.averageReviewRate
        end

        def averageReviewSetRate
            return @contents.reviewSet.stats.averageReviewRate
        end

        # Returns the number of successes needed before the review set is known
        def reviewsLeft
            return 10 - @contents.reviewSet.stats.timesInTargetZone
        end

        # Returns the percentage of items in the review set guessed 
        # correctly in the last 10 guesses
        def recentReviewAccuracy
            return @contents.reviewSet.stats.recentAccuracy
        end

        # Returns a string showing the status when reviewing items 
        # in the review set
        def reviewStatus
            retVal = "     #{self.recentReviewAccuracy}%"
            if @contents.reviewSet.stats.inTargetZone?
                retVal += " - #{self.reviewsLeft}"
            end
            return retVal
        end

        def forgottenSetItemsViewed
            return @contents.forgottenSet.stats.reviewed
        end

        def reviewSetItemsViewed
            return @contents.reviewSet.stats.reviewed
        end

        def workingSetItemsLearned
            return @contents.workingSet.stats.promoted
        end

        def forgottenSetReviewPace
            return @contents.forgottenSet.stats.reviewPace
        end

        def reviewSetReviewPace
            return @contents.reviewSet.stats.reviewPace
        end

        def workingSetLearnedPace
            return @contents.workingSet.stats.promotionPace
        end
       
        # Percentage of time spent learning compared to time spent reviewing
        # review set and forgotten set items.
        def learnTimePercent
            total = workingSetLearnedPace + 
                reviewSetReviewPace + forgottenSetReviewPace
            if total > 0
                return ((workingSetLearnedPace * 100) / total).to_i
            else
                return 0
            end
        end
    
    end
end
