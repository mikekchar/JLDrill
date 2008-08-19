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
                @vocab.kanji + "\n"
            else
                ""
            end
        end

        def reading
            if !@vocab.reading.nil?
                @vocab.reading + "\n"
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
                @vocab.definitions + "\n"
            else
                ""
            end
        end
        
        def vocab=(vocab)
            @vocab.assign(vocab)
            @quiz.setNeedsSave(true)
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

        def questionKanji
            ""
        end

        def questionReading
            ""
        end
        
        def questionDefinitions
            ""
        end
        
        def questionHint
            ""
        end

        def answerKanji
            ""
        end

        def answerReading
            ""
        end
        
        def answerDefinitions
            ""
        end
        
        def answerHint
            ""
        end
        
    end
    
    # The first kind of Problem shown.  It lets you read it in Japanese and
    # guess the English
    class ReadingProblem < Problem
        def initialize(vocab, quiz)
            super(vocab, quiz)
            @level = 0
        end
    
        def question
            kanji + reading + hint
        end    

        def answer
            definitions
        end
        
        def questionKanji
            kanji
        end

        def questionReading
            reading
        end
        
        def questionHint
            hint
        end
        
        def answerDefinitions
            definitions
        end

    end
    
    # Test your kanji reading.  Read the kanji and guess the reading and definitions
    class KanjiProblem < Problem
        def initialize(vocab, quiz)
            super(vocab, quiz)
            @level = 2
        end
    
        def question
            kanji
        end
        
        def answer
            reading + definitions + hint
        end
        
        def questionKanji
            kanji
        end
        
        def answerReading
            reading
        end
        
        def answerDefinitions
            definitions
        end
        
        def answerHint
            hint
        end
    end
    
    # Shows you the English and you guess the kanji and reading
    class MeaningProblem < Problem
        def initialize(vocab, quiz)
            super(vocab, quiz)
            @level = 1
        end
    

        def question
            definitions
        end
        
        def answer
            kanji + reading + hint
        end
        
        def questionDefinitions
            definitions
        end
        
        def answerKanji
            kanji
        end
        
        def answerReading
            reading
        end
        
        def answerHint
            hint
        end
    end

end
