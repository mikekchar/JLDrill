module JLDrill

    # Represents a single question/answer pair in a quiz
    class Problem
        attr_reader :item, :level, :requestedLevel
        attr_writer :requestedLevel
        
        def initialize(item, quiz)
            @item = item
            @level = -1
            @requestedLevel = -1
            @quiz = quiz
            @questionParts = []
            @answerParts = []
            @vocab = item.to_o
            @displayOnly = false
            @preview = false
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
            @quiz.problemModified(self)
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
