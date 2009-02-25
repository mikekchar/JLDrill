require 'jldrill/model/Item'
require 'jldrill/model/items/ItemStatus'

module JLDrill

    # Statistics for a quiz session
    class Statistics
    
        class LevelStats
            def initialize
                @num = 0
                @correct = 0
            end
            
            def correct
                @correct += 1
                @num += 1
            end
            
            def incorrect
                @num += 1
            end
            
            def total
                @num
            end
            
            def accuracy
                if @num > 0
                    ((@correct.to_f / @num.to_f) * 100).to_i
                else
                    nil
                end
            end
        end

        class StatsTimer
            attr_reader :total, :startedAt
        
            def initialize
                @total = 0
                @startedAt = nil
            end
            
            def start
                stop
                @startedAt = Time.now
            end

            def running?
                !@startedAt.nil?
            end
                        
            def stop
                if running?
                    @total += Time.now.to_i - @startedAt.to_i
                    @startedAt = nil
                end
            end
        end
    
        attr_reader :estimate, :lastTen, :confidence, :levels, 
                        :timesInTargetZone, :learned, :reviewed
    
        attr_writer :learned, :reviewed
        
        MINIMUM_CONFIDENCE = 0.009
        
        def initialize
            @estimate = 0
            @correct = 0
            @incorrect = 0
            @lastTen = []
            @inTargetZone = false
            @timesInTargetZone = 0
            @levels = []
            1.upto(8) do
                @levels.push(LevelStats.new)
            end
            @learned = 0
            @reviewed = 0
            @reviewTimer = StatsTimer.new
            @learnTimer = StatsTimer.new
            @currentTimer = nil
            resetConfidence 
        end
        
        def record(bool)
            @lastTen.push(bool)
            while @lastTen.size > 10
                @lastTen.delete_at(0)
            end
            if inTargetZone?
                @timesInTargetZone += 1
            else
                @timesInTargetZone = 0
            end
        end
        
        def recentAccuracy
            retVal = 0
            if @lastTen.size > 0
                0.upto(@lastTen.size) do |i|
                    if @lastTen[i]
                        retVal += 1
                    end
                end
                retVal = (retVal * 100 / @lastTen.size).to_i
            end
            retVal
        end
        
        def inTargetZone?
            # Don't start the countdown until we have reviewed
            # at least 10 item.
            if @reviewed <= 10
                return false
            end
            if !@inTargetZone
                if recentAccuracy >= 90
                    @inTargetZone = true
                end
            else
                if (recentAccuracy < 90) && (@confidence < 90)
                    @inTargetZone = false
                end
            end
            return @inTargetZone
        end

        def findRange(level)
            low = 0
            high = 5
            1.upto(level) do
                if low == 0
                    low = 5
                else
                    low = low * 2
                end
                high = low * 2
            end
            low..high
        end
                    
        def getLevel(item)
            level = 0
            found = false
            while (level <= 6) && !found
                if item.status.durationWithin?(findRange(level))
                    found = true
                else
                    level += 1
                end
            end
            return @levels[level]
        end
        
        def correct(item)
            # currently only level 4 items are reviewed
            if item.status.bin != 4
                return
            end
            @correct += 1
            @reviewed += 1
            level = getLevel(item)
            if !level.nil?
                level.correct
            end
            record(true)
            reEstimate
            calculateConfidence(true)
        end

        def incorrect(item)
            # currently only level 4 items are reviewed
            if item.status.bin != 4
                return
            end
            @incorrect += 1
            @reviewed += 1
            level = getLevel(item)
            if !level.nil?
                level.incorrect
            end
            record(false)
            reEstimate
            calculateConfidence(false)
        end
        
        def correct=(value)
            @correct = value
            reEstimate
        end
        
        def incorrect=(value)
            @incorrect = value
            reEstimate
        end

        # Returns the actual % accuracy of the quiz in an integer 
        def accuracy
            retVal = 0
            if @incorrect == 0
                if @correct != 0
                    retVal = 100
                end
            else
                retVal = ((@correct * 100) / total).to_i
            end
            retVal
        end
        
        def total
            @correct + @incorrect
        end
        
        # Generates an estimate of the % accuracy in an integer
        def reEstimate
            hop = ((recentAccuracy - @estimate) * 0.3).to_i
            retVal = @estimate + hop
            if (retVal > 100) then retVal = 100 end
            if (retVal < 0) then retVal = 0 end
            @estimate = retVal
        end

        # Calculates a Bayesian estimate (I think!) of the confidence that
        # the items seen to this point were known to an accuracy of at
        # least 90%.
        #
        # How this is calculated:
        #    According to Bayes law, P(H|E) = P(E|H) * P(H) / P(E)
        #    Where:
        #       P(H|E) is the probability that the hypothesis is correct
        #              given the evidence.  
        #       P(E|H) is the probability that the evididence would be
        #              shown if the hypothesis were correct.
        #       P(H)   is the probability that the hypothesis is correct
        #              given any evidence.
        #       P(E)   is the probability that the evidence would be seen
        #              in all cases.
        #
        #   This value is calculated incrementally in the following fashion:
        #       P[n] = P(E|H) * P[n-1] / P(E)
        #   i.e., the nth value of P is dependent on the n-1th value of P
        #
        #   In our case, I will assume that the distribution of the 
        #   probabilities is uniform (probably wrong!) and say that
        #   if we got the question right
        #        P(E|H) = 0.95 
        #             that is, our probability of getting it right is
        #             somewhere between 90 and 100%.  I assume uniform
        #             distribution, therefore the average is in the middle.
        #   or if we got the question wrong
        #        P(E|H) = 0.05
        #             obviously, the probability of getting it wrong given
        #             the hypothesis is 1 minus the probability of getting
        #             it right.
        #        P(E) = sum(probabilities for all the hypotheses)
        #             = P(chance < 90) + P(chance is 90+%)
        #        P(chance < 90) = 0.45(1 - P[n-1])
        #             that is, it's equal to 1/2 the range between 0 and 90
        #             times the probability that hypothesis is wrong.
        #        P(chance > 90) = 0.95P[n-1]
        #             that is, it's equal to 1/2 the range between 90 and 100
        #             times the probability that the hypothesis is right.
        #             So...
        #        P(E) = 0.45(1 - P[n-1]) + 0.95P[n-1]
        #
        #    Giving a final answer of
        #        P[n] = P(E|H) * P[n-1] / (0.45(1 - P[n-1]) + 0.95P[n-1])
        #
        #    I fully expect this is completely wrong due to my lack of
        #    ability in math and statistics.  But on the other hand, I won't
        #    care much as long as appears from the user's point of view to
        #    be working.
        def calculateConfidence(wasCorrect)
            if wasCorrect
                pEH = 0.95
            else
                pEH = 0.05
            end
            pE = (0.45 * (1.0 - @confidence)) + (0.95 * @confidence)
            @confidence = (pEH * @confidence) / pE
            if @confidence < MINIMUM_CONFIDENCE
                @confidence = MINIMUM_CONFIDENCE
            end
        end
        
        def resetConfidence
            @confidence = MINIMUM_CONFIDENCE
        end

        def startTimer(isReview)
            if !@currentTimer.nil?
                @currentTimer.stop
            end
            if isReview
                @currentTimer = @reviewTimer
            else
                @currentTimer = @learnTimer
            end
            @currentTimer.start
        end

        def learnTime
            @learnTimer.total
        end
        
        def reviewTime
            @reviewTimer.total
        end
        
        def roundToOneDecimal(value)
            value = value * 10.0
            value = value.round
            value = value.to_f / 10.0
            value
        end

        def learnPace
            if @learned > 0
                roundToOneDecimal(learnTime.to_f / @learned.to_f)
            else
                0.0
            end
        end

        def reviewPace
            if @reviewed > 0
                roundToOneDecimal(reviewTime.to_f / @reviewed.to_f)
            else
                0.0
            end
        end
        
        def learnTimePercent
            total = learnPace + reviewPace
            if total > 0
                ((learnPace * 100) / total).to_i
            else
                0
            end
        end
    end
end
