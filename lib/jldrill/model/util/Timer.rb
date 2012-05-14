# encoding: utf-8
module JLDrill
    class Timer
        attr_reader :startedAt
        
        def initialize
            reset
        end

        def reset
            @total = 0.0
            @startedAt = nil
        end

        def assign(timer)
            @total = timer.total
            @startedAt = timer.startedAt
        end
        
        def start
            stop
            @startedAt = Time.now
        end

        def startedXSecondsAgo(seconds)
            if !running?
                start
            end
            @startedAt -= seconds
        end

        def running?
            !@startedAt.nil?
        end
        
        def stop
            if running?
                @total += Time.now.to_f - @startedAt.to_f
                @startedAt = nil
            end
        end

        def total
            if running?
                return Time.now.to_f - @startedAt.to_f
            else
                return @total
            end
        end
    end
end
