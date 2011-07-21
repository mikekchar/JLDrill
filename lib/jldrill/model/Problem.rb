# encoding: utf-8
module JLDrill

    # Represents a single question/answer pair in a quiz
    class Problem
        attr_reader :item, :level, :requestedLevel,
                    :questionParts, :answerParts
        attr_writer :requestedLevel
        
        def initialize(item)
            @item = item
            @level = -1
            @requestedLevel = -1
            @questionParts = []
            @answerParts = []
            @vocab = item.to_o
            @displayOnly = false
            @preview = false
        end

        # Override in the concrete classes
        def name
            return "Problem"
        end

        def assign(value)
            @item = value.item
            @level = value.level
            @requestedLevel = value.requestedLevel
            @questionParts = value.questionParts
            @answerParts = value.answerParts
            setDisplayOnly = value.displayOnly?
            setPreview = value.preview?
        end

        def eql?(value)
            return @item == value.item &&
                @level == value.level &&
                @requestedLevel == value.requestedLevel &&
                @questionParts == value.questionParts &&
                @answerParts == value.answerParts &&
                displayOnly? == value.displayOnly? &&
                preview? == value.preview?
        end

        def to_s
            retVal = "/" + name
            return retVal
        end

        def parse(part)
            return false
        end
        
        def setDisplayOnly(bool)
            @displayOnly = bool
        end

        def setPreview(bool)
            @preview = bool
        end

        def preview?
            return @preview
        end

        def vocab=(vocab)
            @vocab.assign(vocab)
            @item.setContents(vocab.contentString)
            @item.problemModified(self)
        end

        # Returns true if the current problem contains the vocabulary
        # passed in.
        def contains?(vocab)
            return @vocab.eql?(vocab)
        end

        # Return a string showing what bin this problem is from
        def status
            retVal = "     "
            bin = @item.bin
            if bin < 4
                if bin == 0
                    retVal += "New"
                else
                    retVal += bin.to_s
                end
            else
                retVal += "+#{@item.itemStats.consecutive}"
                if @item.schedule.reviewed?
                    retVal += ", #{@item.schedule.reviewedDate}"
                end
            end
            retVal += " --> #{@item.schedule.potentialScheduleInDays} days"
            return retVal
        end

        def evaluateAttribute(name)
            retVal = eval("@vocab." + name)
            if retVal.nil?
                retVal = ""
            end
            return retVal
        end

        def evaluateParts(parts)
            retVal = ""
            parts.each do |part|
                value = evaluateAttribute(part)
                if !value.empty?
                    retVal += value + "\n"
                end
            end
            retVal
        end
        
        def displayOnly?
            return @displayOnly
        end

        def publishParts(parts, target)
            if preview?
                target.previewMode
            elsif displayOnly?
                target.displayOnlyMode
            else
                target.normalMode
            end
            parts.each do |part|
                value = evaluateAttribute(part)
                if !value.empty?
                    if ((part == "reading") && (largeReading?))
                        target.receive("kanji", value)
                    else
                        target.receive(part, value)
                    end
                end
            end
        end

        def question
            evaluateParts(@questionParts)
        end

        def answer
            evaluateParts(@answerParts)
        end
        
        def publishQuestion(target)
            publishParts(@questionParts, target)
        end

        def publishAnswer(target)
            publishParts(@answerParts, target)
        end

        # Currently always valid.
        def valid?
            return true
        end

        # By default, don't print the reading in large print
        def largeReading?
            return false
        end

    end
    
end
