require 'jldrill/model/Config'

module JLDrill

    # Options for the standard quiz.
    class Options
        attr_reader :randomOrder, :promoteThresh, :introThresh,
                    :reviewMode, :dictionary, :reviewMeaning, 
                    :reviewKanji, :reviewReading, :reviewOptionsSet

        RANDOM_ORDER_RE = /^Random Order/
        PROMOTE_THRESH_RE = /^Promotion Threshold: (.*)/
        INTRO_THRESH_RE = /^Introduction Threshold: (.*)/
        DICTIONARY_RE = /^Dictionary: (.*)/
        REVIEW_MEANING_RE = /^Review Meaning/
        REVIEW_KANJI_RE = /^Review Kanji/
        REVIEW_READING_RE = /^Review Reading/

        def initialize(quiz)
            @quiz = quiz
            @randomOrder = false
            @promoteThresh = 2
            @introThresh = 10
            @reviewMode = false
			@dictionary = nil
            @reviewOptionsSet = false
            defaultReviewOptions
        end
        
        def clone
            retVal = Options.new(@quiz)
            retVal.randomOrder = @randomOrder
            retVal.promoteThresh = @promoteThresh
            retVal.introThresh = @introThresh
            retVal.reviewMode = @reviewMode
			retVal.dictionary = @dictionary
            setReviewOptions(@reviewOptionsSet)
            retVal.reviewMeaning = @reviewMeaning
            retVal.reviewKanji = @reviewKanji
            retVal.reviewReading = @reviewReading
            retVal
        end
        
        def eql?(options)
            options.randomOrder == @randomOrder &&
            options.promoteThresh == @promoteThresh &&
            options.introThresh == @introThresh &&
            options.reviewMode == @reviewMode &&
			options.dictionary == @dictionary &&
            options.reviewOptionsSet == @reviewOptionsSet &&
            options.reviewMeaning == @reviewMeaning &&
            options.reviewKanji == @reviewKanji &&
            options.reviewReading == @reviewReading
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
            @randomOrder = options.randomOrder
            @promoteThresh = options.promoteThresh
            @introThresh = options.introThresh
			@dictionary = options.dictionary
            setReviewOptions(options.reviewOptionsSet)
            @reviewMeaning = options.reviewMeaning
            @reviewKanji = options.reviewKanji
            @reviewReading = options.reviewReading
            if !@quiz.nil?
                @quiz.recreateProblem
            end
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

        # Note: Review Mode isn't saved so no save needed    
        def reviewMode=(value)
            if @reviewMode != value
                @reviewMode = value
                modifiedButNoSaveNeeded
            end
        end
    	
		def dictionary=(value)
			if @dictionary != value
				@dictionary = value
				saveNeeded
			end
		end

        def clearReviewOptions
            @reviewMeaning = false
            @reviewKanji = false
            @reviewReading = false
        end

        def defaultReviewOptions
            @reviewMeaning = true
            @reviewKanji = true
            @reviewReading = false
        end

        def setReviewOptions(value)
            if (value == true) 
                if (@reviewOptionsSet == false)
                    clearReviewOptions
                    saveNeeded
                end
            else
                defaultReviewOptions
                saveNeeded
            end
            @reviewOptionsSet = value
        end
        
        def reviewMeaning=(value)
            setReviewOptions(true)
            if @reviewMeaning != value
                @reviewMeaning = value
                saveNeeded
            end
        end

        def reviewKanji=(value)
            setReviewOptions(true)
            if @reviewKanji != value
                @reviewKanji = value
                saveNeeded
            end
        end

        def reviewReading=(value)
            setReviewOptions(true)
            if @reviewReading != value
                @reviewReading = value
                saveNeeded
            end
        end

        # Return an array containing the allowed levels for the
        # drills.
        def allowedLevels
            retVal = []
            if reviewReading
                retVal.push(0)
            end
            if reviewKanji
                retVal.push(1)
            end
            if reviewMeaning
                retVal.push(2)
            end
            # If the user hasn't selected any levels, then
            # default to kanji and meaning
            if retVal.size == 0
                retVal.push(1)
                retVal.push(2)
            end
            return retVal
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
				when DICTIONARY_RE
					self.dictionary = $1.to_i
                when REVIEW_MEANING_RE
                    self.reviewMeaning = $1.to_i
                when REVIEW_KANJI_RE
                    self.reviewKanji = $1.to_i
                when REVIEW_READING_RE
                    self.reviewReading = $1.to_i
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
			if(!@dictionary.nil?)
				retVal += "Dictionary: #{@dictionary}\n"
			end
            if(@reviewMeaning)
                retVal += "Review Meaning\n"
            end
            if(@reviewKanji)
                retVal += "Review Kanji\n"
            end
            if(@reviewReading)
                retVal += "Review Reading\n"
            end
            retVal
        end
    end
end

