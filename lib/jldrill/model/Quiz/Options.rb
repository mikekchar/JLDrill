
module JLDrill

    # Options for the standard quiz.
    class Options
        attr_reader :randomOrder, :promoteThresh, :introThresh, :oldThresh,
                        :strategyVersion, :reviewMode

        RANDOM_ORDER_RE = /^Random Order/
        PROMOTE_THRESH_RE = /^Promotion Threshold: (.*)/
        INTRO_THRESH_RE = /^Introduction Threshold: (.*)/
        OLD_THRESH_RE = /^Old Threshold: (.*)/
        STRATEGY_VERSION_RE = /^Strategy Version: (.*)/
            
        def initialize(quiz)
            @quiz = quiz
            @randomOrder = false
            @promoteThresh = 2
            @introThresh = 10
            @oldThresh = 90
            @strategyVersion = 0
            @reviewMode = false
        end
        
        def clone
            retVal = Options.new(@quiz)
            retVal.randomOrder = @randomOrder
            retVal.promoteThresh = @promoteThresh
            retVal.introThresh = @introThresh
            retVal.oldThresh = @oldThresh
            retVal.strategyVersion = @strategyVersion
            retVal.reviewMode = @reviewMode
            retVal
        end
        
        def eql?(options)
            options.randomOrder == @randomOrder &&
            options.promoteThresh == @promoteThresh &&
            options.introThresh == @introThresh &&
            options.oldThresh == @oldThresh &&
            options.strategyVersion == @strategyVersion &&
            options.reviewMode == @reviewMode
        end
            
        def update
            @quiz.update unless @quiz.nil?
        end
        
        # Assigns all the options from one to the other, but
        # does *keeps the same quiz*
        def assign(options)
            @randomOrder = options.randomOrder
            @promoteThresh = options.promoteThresh
            @introThresh = options.introThresh
            @oldThresh = options.oldThresh
            @strategyVersion = options.strategyVersion
            update
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

        def strategyVersion=(value)
            @strategyVersion = value
            update
        end

        # Note: Review Mode isn't saved, so this doesn't trigger an
        #       update in the quiz.        
        def reviewMode=(value)
            @reviewMode = value
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
                when STRATEGY_VERSION_RE 
                    self.strategyVersion = $1.to_i
                else
                    parsed = false
            end
            parsed
        end
        
        # Return a string showing the current state of the options
        def status
            retVal = @strategyVersion.to_s
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
            retVal += "Strategy Version: #{@strategyVersion}\n"
            retVal
        end
    end
end

