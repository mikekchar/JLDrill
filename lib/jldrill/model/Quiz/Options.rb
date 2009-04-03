
module JLDrill

    # Options for the standard quiz.
    class Options
        attr_reader :randomOrder, :promoteThresh, :introThresh, :oldThresh,
                        :reviewMode

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
            @reviewMode = false
        end
        
        def clone
            retVal = Options.new(@quiz)
            retVal.randomOrder = @randomOrder
            retVal.promoteThresh = @promoteThresh
            retVal.introThresh = @introThresh
            retVal.oldThresh = @oldThresh
            retVal.reviewMode = @reviewMode
            retVal
        end
        
        def eql?(options)
            options.randomOrder == @randomOrder &&
            options.promoteThresh == @promoteThresh &&
            options.introThresh == @introThresh &&
            options.oldThresh == @oldThresh &&
            options.reviewMode == @reviewMode
        end
            
        def saveNeeded
            @quiz.setNeedsSave(true) unless @quiz.nil?
        end
        
        def modifiedButNoSaveNeeded
            @quiz.update unless @quiz.nil?
        end
        
        # Assigns all the options from one to the other, but
        # does *keeps the same quiz*
        def assign(options)
            self.randomOrder = options.randomOrder
            self.promoteThresh = options.promoteThresh
            self.introThresh = options.introThresh
            self.oldThresh = options.oldThresh
        end
        
        def randomOrder=(value)
            if @randomOrder != value
                @randomOrder = value
                saveNeeded
            end
        end

        def promoteThresh=(value)
            if @promoteThresh != value
                @promoteThresh = value
                saveNeeded
            end
        end

        def introThresh=(value)
            if @introThresh != value
                @introThresh = value
                saveNeeded
            end
        end

        def oldThresh=(value)
            if @oldThresh != value
                @oldThresh = value
                saveNeeded
            end
        end

        # Note: Review Mode isn't saved so no save needed    
        def reviewMode=(value)
            if @reviewMode != value
                @reviewMode = value
                modifiedButNoSaveNeeded
            end
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

