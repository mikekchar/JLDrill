
module JLDrill

    # Options for the standard quiz.
    class Options
        attr_reader :randomOrder, :promoteThresh, :introThresh, :oldThresh

        RANDOM_ORDER_RE = /^Random Order/
        PROMOTE_THRESH_RE = /^Promotion Threshold: (.*)/
        INTRO_THRESH_RE = /^Introduction Threshold: (.*)/
        OLD_THRESH_RE = /^Old Threshold: (.*)/
            
        def initialize(quiz)
            @quiz = quiz
            @randomOrder = false
            @promoteThresh = 2
            @introThresh = 10
            @oldThresh = 90
        end
            
        def update
            @quiz.update
        end

        def randomOrder=(value)
            @randomOrder = value
            update
        end

        def promoteThresh=(value)
            @promoteThresh = value
            update
        end

        def introThresh=(value)
            @introThresh = value
            update
        end

        def oldThresh=(value)
            @oldThresh = value
            update
        end
            
        def parseLine(line)
            parsed = true
            case line
                when RANDOM_ORDER_RE
                    self.randomOrder = true
                when PROMOTE_THRESH_RE
                    self.promoteThresh = $1.to_i
                when INTRO_THRESH_RE 
                    self.introThresh = $1.to_i
                else
                    parsed = false
            end
            parsed
        end
        
        # Return a string showing the current state of the options
        def status
            retVal = ""
            if(@randomOrder) then retVal += "R" end
            retVal += "(#{@promoteThresh},#{@introThresh})"
            retVal
        end
        
        def to_s
            retVal = ""
            if(@randomOrder)
                retVal += "Random Order\n"
            end
            retVal += "Promotion Threshold: #{@promoteThresh}\n"
            retVal += "Introduction Threshold: #{@introThresh}\n"
            retVal
        end
    end
end

