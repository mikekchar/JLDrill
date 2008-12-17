require 'jldrill/model/Vocabulary'

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
            @vocab = Vocabulary.create(item.to_s)
        end
        
        def Problem.create(level, item, quiz)
            case level
                when 0
                    problem = ReadingProblem.new(item, quiz)
                when 1
                    v = Vocabulary.create(item.to_s)
                    if !v.kanji.nil?
                        problem = KanjiProblem.new(item, quiz)
                    else
                        problem = MeaningProblem.new(item, quiz)
                    end
                when 2
                    problem = MeaningProblem.new(item, quiz)
                else
                   problem = ReadingProblem.new(item, quiz)
             end
            problem.requestedLevel = level
            problem
        end

        def kanji
            if !@vocab.kanji.nil?
                @vocab.kanji
            else
                ""
            end
        end

        def reading
            if !@vocab.reading.nil?
                @vocab.reading
            else
                ""
            end
        end

        def hint
            if !@vocab.hint.nil?
                "Hint: " + @vocab.hint
            else
                ""
            end
        end

        def definitions
            if @vocab.definitions != ""
                @vocab.definitions
            else
                ""
            end
        end
        
        def vocab=(vocab)
            @vocab.assign(vocab)
            @item.setContents(vocab.contentString)
            @quiz.setNeedsSave(true)
            @quiz.problemModified
        end

        # Return a string showing what bin this problem is from
        def status
            retVal = "     "
            bin = @item.status.bin
            if bin < 4
                if bin == 0
                    retVal += "New"
                else
                    retVal += bin.to_s
                end
            else
                retVal += "+#{@item.status.consecutive}"
                if @item.status.reviewed?
                    retVal += ", #{@item.status.reviewedDate}"
                end
            end
            retVal += " --> #{@item.status.potentialScheduleInDays} days"
        end

        def evaluateAttribute(name)
            eval("self." + name)
        end

        def evaluateParts(parts)
            retVal = ""
            parts.each do |part|
                retVal += evaluateAttribute(part) + "\n"
            end
            retVal
        end
        
        def publishParts(parts, target)
            parts.each do |part|
                value = evaluateAttribute(part)
                target.receive(part, value)
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
        
    end
    
    # The first kind of Problem shown.  It lets you read it in Japanese and
    # guess the English
    class ReadingProblem < Problem
        def initialize(item, quiz)
            super(item, quiz)
            @level = 0
            @questionParts = ["kanji", "reading", "hint"]
            @answerParts = ["definitions"]
        end
    end
    
    # Test your kanji reading.  Read the kanji and guess the reading and definitions
    class KanjiProblem < Problem
        def initialize(item, quiz)
            super(item, quiz)
            @level = 2
            @questionParts = ["kanji"]
            @answerParts = ["reading", "definitions", "hint"]
        end
    end
    
    # Shows you the English and you guess the kanji and reading
    class MeaningProblem < Problem
        def initialize(item, quiz)
            super(item, quiz)
            @level = 1
            @questionParts = ["definitions"]
            @answerParts = ["kanji", "reading", "hint"]
        end
    end

end
