module JLDrill
    class Timer
        attr_reader :total, :startedAt
        attr_writer :startedAt
        
        def initialize
            reset
        end

        def reset
            @total = 0
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
end
