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

        def contents
            @quiz.contents
        end
                
        def underIntroThresh
            contents.workingSetSize < @quiz.options.introThresh
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

        def unseen?(bin, index)
            !contents.bins[bin][index].status.seen
        end
        
        def findUnseen(bin)
            index = 0
            # find the first one that hasn't been seen yet
            while (index < contents.bins[bin].length) && !unseen?(bin, index)
                index += 1
            end
            
            # wrap to the first item if they have all been seen
            if (index >= contents.bins[bin].length) then index = 0 end
            index
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

            if((!@quiz.options.randomOrder) && (bin == 0))
                index = 0
            elsif (bin == 4)
                index = findUnseen(bin)
                contents.bins[bin][index].status.seen = true
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
        
        def createProblem(vocab)
            # Drill at random levels in bin 4, but don't drill reading
            if vocab.status.bin == 4
                level = rand(2) + 1
            else
                # Otherwise drill for the specific bin
                level = vocab.status.bin - 1
            end
            Problem.create(level, vocab)
        end
        
        # Move the specified vocab to the specified bin
        def moveToBin(vocab, bin)
            contents.moveToBin(vocab, bin)
        end

        def promote(vocab)
            if !vocab.nil? && (vocab.status.bin + 1 < contents.bins.length) 
                moveToBin(vocab, vocab.status.bin + 1)
                vocab.status.level = vocab.status.bin - 1 unless vocab.status.bin - 1 > 2
            end
        end

        def demote(vocab)
            if vocab
                vocab.status.level = 0
                if (vocab.status.bin != 0)
                    moveToBin(vocab, 1)
                else
                	# Demoting bin 0 items is non-sensical, but it should do
	                # something sensible anyway.
                    moveToBin(vocab, 0)
                end
            end
        end

        def adjustQuizOld(good)
            if(@quiz.currentProblem.vocab.status.bin == 4)
                if(good)
                    @stats.correct
                else
                    @stats.incorrect
                end
            end
        end
  
        def correct
            vocab = @quiz.currentProblem.vocab
            adjustQuizOld(true)
            if(vocab)
                vocab.status.schedule
                vocab.status.markReviewed
                vocab.status.score += 1
                if(vocab.status.score >= @quiz.options.promoteThresh)
                    promote(vocab)
                end
                if vocab.status.bin == 4
                    vocab.status.consecutive += 1
                    contents.bins[4].sort! do |x, y|
                        x.status.scheduledTime <=> y.status.scheduledTime
                    end
                end
                @quiz.update
            end
        end

        def incorrect
            vocab = @quiz.currentProblem.vocab
            adjustQuizOld(false)
            if(vocab)
                vocab.status.unschedule
                vocab.status.markReviewed
                demote(@quiz.currentProblem.vocab)
                vocab.status.consecutive = 0
                @quiz.update
            end
        end
    end
end
