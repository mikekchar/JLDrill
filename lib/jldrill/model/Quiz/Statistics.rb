module JLDrill

    # Statistics for a quiz session
    class Statistics
        attr_reader :estimate
    
        def initialize
            @estimate = 0
            @correct = 0
            @incorrect = 0
        end
        
        def correct
            @correct += 1
            reEstimate
        end

        def incorrect
            @incorrect += 1
            reEstimate
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
            hop = ((accuracy - @estimate) * 0.3).to_i
            retVal = @estimate + hop
            if (retVal > 100) then retVal = 100 end
            if (retVal < 0) then retVal = 0 end
            @estimate = retVal
        end

    end
end
