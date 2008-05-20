require 'jldrill/model/Quiz/Statistics'

module JLDrill

    # Strategy for a quiz
    class Strategy
        attr_reader :stats
    
        def initialize(quiz)
            @quiz = quiz
            @stats = Statistics.new
        end
        
        # Returns a string showing the status of the quiz with this strategy
        def status
            "Known: #{@stats.estimate}%"
        end

        def correct
            @stats.correct
        end
        
        def incorrect
            @stats.incorrect
        end        

    end
end
