require 'jldrill/model/Quiz/Statistics'

module JLDrill

    # Strategy for a quiz
    class Strategy
        attr_reader :stats
    
        def initialize(quiz)
            @quiz = quiz
            @stats = Statistics.new
        end
        
        # Returns a string showing the status of the quiz with this strategy
        def status
            "Known: #{@stats.estimate}%"
        end

        def correct
            @stats.correct
        end
        
        def incorrect
            @stats.incorrect
        end
        
        def contents
            @quiz.contents
        end
        
                
        def underIntroThresh
            (contents.bins[1].length + contents.bins[2].length) < @quiz.options.introThresh
        end
  
        def underReviewThresh
            @stats.estimate < @quiz.options.oldThresh
        end
        
        def randomBin(from, to)
            if from >= to
                return to
            elsif (contents.bins[from].length == 0) || (rand(2) == 0)
                return randomBin(from + 1, to)
            else
                return from
            end
        end
        
        def getBin
            retVal = 0
            if (contents.bins[4].length == contents.length)
                retVal = 4
            elsif (contents.bins[0].length == 0)
                if underIntroThresh && underReviewThresh && 
                    (contents.bins[4].length > 5)
                    retVal = 4
                else
                    retVal = randomBin(1, 3)
                end
            else
                if underIntroThresh
                    if underReviewThresh && (contents.bins[4].length > 5)
                        retVal = 4
                    else
                        if contents.bins[4].length > 5
                            if rand(10) > 8
                                retVal = 4
                            else
                                retVal = 0
                            end
                        else
                            retVal = 0
                        end
                    end
                else
                    retVal = randomBin(1, 3)
                end
            end
            retVal
        end

        def getVocab
            if(contents.length == 0)
                return nil
            end

            deadThresh = 10
            bin = getBin
            until (contents.bins[bin].length > 0) || (deadThresh == 0)
                bin = getBin
                deadThresh -= 1
            end
            if (deadThresh == 0)
                print "Warning: Deadlock broken in getVocab\n"
                print status + "\n"
            end

            if((!@quiz.options.randomOrder) && (bin == 0)) || (bin == 4)
                index = 0
            else
                index = rand(contents.bins[bin].length)
            end

            vocab = contents.bins[bin][index] 
            if bin == 0 then promote(vocab) end
            return vocab
        end

        def getUniqueVocab
            if(contents.length == 0)
                return
            end

            vocab = getVocab
            deadThresh = 10
            if(contents.length > 1)
                # Don't show the same item twice in a row
                until (vocab != @last) || (deadThresh == 0)
                    vocab = getVocab
                    deadThresh -= 1 
                end
                if (deadThresh == 0)
                    print "Warning: Deadlock broken in getUniqueVocab\n"
                    print status + "\n"
                end
            end
            @last = vocab
            vocab
        end
        
        # Move the specified vocab to the specified bin
        def moveToBin(vocab, bin)
            contents.moveToBin(vocab, bin)
        end

        def promote(vocab)
            if !vocab.nil? && (vocab.status.bin + 1 < contents.bins.length) 
                if vocab.status.bin != 2 || vocab.status.level == 2
                    moveToBin(vocab, vocab.status.bin + 1)
                else
                    if !vocab.kanji.nil?
                        vocab.status.level += 1
                    else
                        vocab.status.level = 2
                    end
                end
            end
        end

        def demote(vocab, level=0)
            if vocab
                # Reset the level and bin to the one that
                # the user failed on.
 
                vocab.status.level = level
                if level == 0
                    moveToBin(vocab, 1)
                else
                    moveToBin(vocab, 2)
                end
            end
        end

    
    end
end
