# encoding: utf-8
require 'jldrill/model/Config'
require 'Context/Publisher'

module JLDrill

    # Options for the standard quiz.
    class Options
        attr_reader :publisher, :randomOrder, :promoteThresh, :introThresh,
                    :reviewMode, :dictionary, :language, :reviewMeaning, 
                    :reviewKanji, :reviewReading, :reviewOptionsSet,
                    :autoloadDic, :tanaka, :forgettingThresh,
                    :interleavedWorkingSet

        attr_writer :reviewOptionsSet

        RANDOM_ORDER_RE = /^Random Order/
        PROMOTE_THRESH_RE = /^Promotion Threshold: (.*)/
        INTRO_THRESH_RE = /^Introduction Threshold: (.*)/
        DICTIONARY_RE = /^Dictionary: (.*)/
        LANGUAGE_RE = /^Language: (.*)/
        REVIEW_MEANING_RE = /^Review Meaning/
        REVIEW_KANJI_RE = /^Review Kanji/
        REVIEW_READING_RE = /^Review Reading/
        AUTOLOAD_DIC_RE = /^Autoload Dictionary/
        FORGETTING_THRESH_RE = /^Forgetting Threshold: (.*)/
        INTERLEAVED_WORKING_SET_RE = /^Interleaved Working Set/

        def initialize(quiz)
            @quiz = quiz
            @publisher = Context::Publisher.new(self)
            @randomOrder = false
            @promoteThresh = 2
            @introThresh = 10
            @reviewMode = false
			@dictionary = nil
            @language = "Japanese"
			@tanaka = nil
            @autoloadDic = false
            @forgettingThresh = 0.0
            @interleavedWorkingSet = false
            defaultReviewOptions
        end
        
        def clone
            retVal = Options.new(@quiz)
            retVal.randomOrder = @randomOrder
            retVal.promoteThresh = @promoteThresh
            retVal.introThresh = @introThresh
            retVal.reviewMode = @reviewMode
            retVal.dictionary = @dictionary
            retVal.language = @language
            retVal.reviewOptionsSet = @reviewOptionsSet
            retVal.reviewMeaning = @reviewMeaning
            retVal.reviewKanji = @reviewKanji
            retVal.reviewReading = @reviewReading
            retVal.autoloadDic = @autoloadDic
            retVal.forgettingThresh = @forgettingThresh
            retVal.interleavedWorkingSet = @interleavedWorkingSet
            return retVal
        end
        
        def eql?(options)
            return options.randomOrder == @randomOrder &&
            options.promoteThresh == @promoteThresh &&
            options.introThresh == @introThresh &&
            options.reviewMode == @reviewMode &&
            options.dictionary == @dictionary &&
            options.language == @language &&
            options.reviewOptionsSet == @reviewOptionsSet &&
            options.reviewMeaning == @reviewMeaning &&
            options.reviewKanji == @reviewKanji &&
            options.autoloadDic == @autoloadDic &&
            options.reviewReading == @reviewReading &&
            options.forgettingThresh == @forgettingThresh &&
            options.interleavedWorkingSet == @interleavedWorkingSet
        end

        def subscribe(subscriber)
            @publisher.subscribe(subscriber, "options")
        end

        def unsubscribe(subscriber)
            @publisher.unsubscribe(subscriber, "options")
        end

        def update
            @publisher.update("options")
        end
            
        def saveNeeded
            @quiz.setNeedsSave(true) unless @quiz.nil?
            update
        end
        
        def modifiedButNoSaveNeeded
            @quiz.update unless @quiz.nil?
            update
        end
        
        # Assigns all the options from one to the other, but
        # does *keeps the same quiz*
        def assign(options)
            self.randomOrder = options.randomOrder
            self.promoteThresh = options.promoteThresh
            self.introThresh = options.introThresh
            self.dictionary = options.dictionary
            self.language = options.language
            @reviewOptionsSet = options.reviewOptionsSet
            self.reviewMeaning = options.reviewMeaning
            self.reviewKanji = options.reviewKanji
            self.reviewReading = options.reviewReading
            self.autoloadDic = options.autoloadDic
            self.forgettingThresh = options.forgettingThresh
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

		def language=(value)
			if @language != value
				@language = value
				saveNeeded
			end
		end

        def autoloadDic=(value)
            if @autoloadDic != value
                @autoloadDic = value
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
            @reviewOptionsSet = false
        end

        # If none of the review options are set, then the options
        # will remain at the default.  But if one of the items is set, then
        # they are all cleared.
        def initializeReviewOptions
            if (@reviewOptionsSet == false)
                clearReviewOptions
            end
            @reviewOptionsSet = true
        end

        # Once the options have finished loading we keep the default
        # as if it had been set by hand.  This needs to be called by
        # the quiz after the file has finished loading
        def optionsFinishedLoading
            @reviewOptionsSet = true
        end
        
        def reviewMeaning=(value)
            initializeReviewOptions
            if @reviewMeaning != value
                @reviewMeaning = value
                saveNeeded
            end
        end

        def reviewKanji=(value)
            initializeReviewOptions
            if @reviewKanji != value
                @reviewKanji = value
                saveNeeded
            end
        end

        def reviewReading=(value)
            initializeReviewOptions
            if @reviewReading != value
                @reviewReading = value
                saveNeeded
            end
        end

        def forgettingThresh=(value)
            if @forgettingThresh != value
                @forgettingThresh = value
                saveNeeded
            end
        end

        def interleavedWorkingSet=(value)
            if @interleavedWorkingSet != value
                @interleavedWorkingSet = value
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
					self.dictionary = $1
				when LANGUAGE_RE
					self.language = $1
                when REVIEW_MEANING_RE
                    self.reviewMeaning = $1.to_i
                when REVIEW_KANJI_RE
                    self.reviewKanji = $1.to_i
                when REVIEW_READING_RE
                    self.reviewReading = $1.to_i
                when AUTOLOAD_DIC_RE
                    self.autoloadDic = true
                when FORGETTING_THRESH_RE
                    self.forgettingThresh = $1.to_f
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
            if(@language != "Japanese")
                retVal += "Language: #{@language}\n"
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
            if(@autoloadDic)
                retVal += "Autoload Dictionary\n"
            end
            if(@forgettingThresh != 0)
                retVal += "Forgetting Threshold: #{@forgettingThresh}\n"
            end
            retVal
        end
    end
end

