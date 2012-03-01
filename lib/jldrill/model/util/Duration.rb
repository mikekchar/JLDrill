# encoding: utf-8
module JLDrill

    # Holds a duration in seconds.  Note that this is an integer value
    # and can't be used for small measurements. A value less than zero
    # means that it is an invalid duration.  Also since it is a signed
    # int you should refrain from using values larger than about 68 years
    
    class Duration

        def initialize(seconds = -1)
            @seconds = seconds
        end

        # assigns this duration to be the same as the one passed in
        def assign(duration)
            @seconds = duration.seconds
        end

        # Returns the duration in seconds
        def seconds
            return @seconds
        end

        # Sets the duration to be equal to the number of seconds passed in
        def seconds=(seconds)
            @seconds = seconds
        end

        # Returns the duration in days as a floating point number
        def days
            return @seconds.to_f / 60.0 / 60.0 / 24.0
        end

        # Sets the duration to be the number of days passed in.  If this
        # happens to end up as a fraction of seconds, the result is truncated.
        def days=(days)
            @seconds = (days * 24 * 60 * 60).to_i
        end

        # Takes an integer as a string and returns a duration.
        def Duration.parse(string)
            duration = string.to_i
            # When to_i fails, it returns 0.  We need to differential
            # between that and a real 0.
            if (duration != 0) || string.start_with?("0")
                return Duration.new(duration)
            else
                # Return an invalid Duration
                return Duration.new()
            end
        end

        # Returns false if the duration isn't valid
        def valid?
            return (@seconds >= 0)
        end

        # Returns the duration as a string representing the number of seconds
        def to_s
            return @seconds.to_s
        end
    end
end


