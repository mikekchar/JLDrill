module JLDrill

    # Represents a single question/answer pair in a quiz
    class Problem
        attr_reader :vocab, :level, :requestedLevel
        attr_writer :requestedLevel
        
        def initialize(vocab, quiz)
            @vocab = vocab
            @level = -1
            @requestedLevel = -1
            @quiz = quiz
            @questionParts = []
            @answerParts = []
        end
        
        def Problem.create(level, vocab, quiz)
            case level
                when 0
                    problem = ReadingProblem.new(vocab, quiz)
                when 1
                    if vocab.kanji
                        problem = KanjiProblem.new(vocab, quiz)
                    else
                        problem = MeaningProblem.new(vocab, quiz)
                    end
                when 2
                    problem = MeaningProblem.new(vocab, quiz)
                else
                   problem = ReadingProblem.new(vocab, quiz)
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
            @quiz.setNeedsSave(true)
            @quiz.problemModified
        end

        # Return a string showing what bin this problem is from
        def status
            retVal = "     "
            if @vocab.status.bin < 4
                retVal += "Bin #{@vocab.status.bin}, "
            else
                retVal += "+#{@vocab.status.consecutive}, "
                if @vocab.status.reviewed?
                    retVal += "Last #{@vocab.status.reviewedDate}, "
                end
            end
            retVal += "--> #{@vocab.status.potentialScheduleInDays} days"
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
                if value != ""
                    eval("target.publish_" + part + "(value)")
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
        
    end
    
    # The first kind of Problem shown.  It lets you read it in Japanese and
    # guess the English
    class ReadingProblem < Problem
        def initialize(vocab, quiz)
            super(vocab, quiz)
            @level = 0
            @questionParts = ["kanji", "reading", "hint"]
            @answerParts = ["definitions"]
        end
    end
    
    # Test your kanji reading.  Read the kanji and guess the reading and definitions
    class KanjiProblem < Problem
        def initialize(vocab, quiz)
            super(vocab, quiz)
            @level = 2
            @questionParts = ["kanji"]
            @answerParts = ["reading", "definitions", "hint"]
        end
    end
    
    # Shows you the English and you guess the kanji and reading
    class MeaningProblem < Problem
        def initialize(vocab, quiz)
            super(vocab, quiz)
            @level = 1
            @questionParts = ["definitions"]
            @answerParts = ["kanji", "reading", "hint"]
        end
    end

end
