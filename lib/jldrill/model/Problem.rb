module JLDrill

    # Represents a single question/answer pair in a quiz
    class Problem
        attr_reader :vocab, :level, :requestedLevel
        attr_writer :requestedLevel
        
        def initialize(vocab)
            @vocab = vocab
            @level = -1
            @requestedLevel = -1
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
                "\nHint: " + @vocab.hint + "\n"
            else
                ""
            end
        end

        def definitions
            if !@vocab.definitions.nil?
                @vocab.definitions + "\n"
            else
                ""
            end
        end
        
        def vocab=(vocab)
            @vocab.assign(vocab)
        end

        # Return a string showing what bin this problem is from
        def status
            "Current: #{@vocab.status.bin}"
        end
        
    end
    
    # The first kind of Problem shown.  It lets you read it in Japanese and
    # guess the English
    class ReadingProblem < Problem
        def initialize(vocab)
            super(vocab)
            @level = 0
        end
    
        def question
            kanji + reading + hint
        end    

        def answer
            definitions
        end    
    end
    
    # Test your kanji reading.  Read the kanji and guess the reading and definitions
    class KanjiProblem < Problem
        def initialize(vocab)
            super(vocab)
            @level = 2
        end
    
        def question
            kanji
        end
        
        def answer
            reading + definitions + hint
        end
    end
    
    # Shows you the English and you guess the kanji and reading
    class MeaningProblem < Problem
        def initialize(vocab)
            super(vocab)
            @level = 1
        end
    

        def question
            definitions
        end
        
        def answer
            kanji + reading + hint
        end
    end

end
