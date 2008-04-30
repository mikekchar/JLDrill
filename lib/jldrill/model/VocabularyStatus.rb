
module JLDrill

    # A memento that keeps track of the drill status for this
    # vocabulary.
    # * score is the number of times the item has been successfully
    # drilled in the current bin.
    # * bin is the number of the bin
    # * level is 0 if meaning has not been introduced 1 if kanji has not been introduced, 2 otherwise (is this right?)
    # * position is the original ordinal position of the item in the quiz
    # * index is the ordinal position of the item in the bin
    #
    # Note: item is not currently being stored in the files and is not outputted
    # in to_s()
    class VocabularyStatus

        SCORE_RE = /^Score: (.*)/
        BIN_RE = /^Bin: (.*)/
        LEVEL_RE = /^Level: (.*)/
        POSITION_RE = /^Position: (.*)/
        LASTREVIEWED_RE = /^LastReviewed: (.*)/
        CONSECUTIVE_RE = /^Consecutive: (.*)/
        SCHEDULEDTIME_RE = /^ScheduledTime: (.*)/
        
        SECONDS_PER_DAY = 60 * 60 * 24

        attr_reader :score, :bin, :level, :position, :index, 
                        :lastReviewed, :consecutive, :scheduledTime
        attr_writer :score, :bin, :level, :position, :index, 
                        :lastReviewed, :consecutive, :scheduledTime


        def initialize(vocab)
            @vocab = vocab
            @score = 0
            @bin = 0
            @level = 0
            @consecutive = 0
            @position = 0
            @lastReviewed = nil
            @scheduledTime = nil
            @index = nil
        end
        
        # Parses a vocabulary value in save format.
        def parse(string)
            parsed = true
            case string
                when SCORE_RE 
                    @score = $1.to_i
                when BIN_RE 
                    @bin = $1.to_i
                when LEVEL_RE
                    @level = $1.to_i
                when POSITION_RE 
                    @position = $1.to_i
                when LASTREVIEWED_RE
                    @lastReviewed = Time.at($1.to_i)
                when CONSECUTIVE_RE 
                    @consecutive = $1.to_i
                when SCHEDULEDTIME_RE
                    @scheduledTime = Time.at($1.to_i)
            else # Not something we understand
                parsed = false
            end
            parsed
        end
        
        # Updates the status for the lastReviewed to be now.
        # Returns the time that it set.
        def markReviewed
            @lastReviewed = Time::now
        end
   
        # Returns true if the item has been marked reviewed at least once
        def reviewed?
            !@lastReviewed.nil?
        end
           
        # Resets the status  
        def reset
            @lastReviewed = nil
            @score = 0
            @consecutive = 0
        end
        
        def scheduled?
            !@scheduledTime.nil?
        end
        
        def schedule
            if !reviewed?
                @scheduledTime = Time::now + SECONDS_PER_DAY
            else
                elapsed = Time::now - @lastReviewed
                @scheduledTime = Time::now + (2 * elapsed)
            end
        end
        
        def unschedule
            @scheduledTime = nil
        end
        
        def scheduledTime
            if !scheduled?
                Time::at(0)
            else
                @scheduledTime
            end
        end
        
        def to_s
            retVal = "/Score: #{@score}" + "/Bin: #{@bin}" + "/Level: #{@level}" +
                "/Position: #{@position}"
            if reviewed?
                retVal += "/LastReviewed: #{@lastReviewed.to_i}"
            end
            if !@consecutive.nil?
                retVal += "/Consecutive: #{@consecutive.to_i}"
            end
            if scheduled?
                retVal += "/ScheduledTime: #{@scheduledTime.to_i}"
            end
            retVal
        end
    end
end
