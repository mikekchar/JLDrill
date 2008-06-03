module JLDrill

    # Statistics for a quiz session
    class Statistics
        attr_reader :estimate, :lastTen
    
        def initialize
            @estimate = 0
            @correct = 0
            @incorrect = 0
            @lastTen = []
        end
        
        def record(bool)
            @lastTen.push(bool)
            while @lastTen.size > 10
                @lastTen.delete_at(0)
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
        
        def correct
            @correct += 1
            record(true)
            reEstimate
        end

        def incorrect
            @incorrect += 1
            record(false)
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
            hop = ((recentAccuracy - @estimate) * 0.3).to_i
            retVal = @estimate + hop
            if (retVal > 100) then retVal = 100 end
            if (retVal < 0) then retVal = 0 end
            @estimate = retVal
        end

    end
end
