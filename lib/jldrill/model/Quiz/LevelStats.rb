# encoding: utf-8
module JLDrill
    # Keeps track of statistics for a particular level
    # @num is the number of tries, @correct is the number that
    # were correct.
    class LevelStats
        def initialize
            @num = 0
            @correct = 0
        end
        
        # Indicate that a trial was correct    
        def correct
            @correct += 1
            @num += 1
        end
        
        # Indicate that a trial was incorrect    
        def incorrect
            @num += 1
        end
        
        # The total number of trials    
        def total
            @num
        end
        
        # Returns the percentage of items scored correctly.
        # Note this returns an integer from 0 to 100.  If the
        # percentage included a fraction, the fraction is truncated.
        def accuracy
            if @num > 0
                ((@correct.to_f / @num.to_f) * 100).to_i
            else
                nil
            end
        end
    end
end

