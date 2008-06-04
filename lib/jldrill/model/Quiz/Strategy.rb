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

        # Returns the contents (i.e. the set of vocabulary) for the quiz
        def contents
            @quiz.contents
        end
        
        # Returns true if the working set is not full
        def underIntroThresh
            contents.workingSetSize < @quiz.options.introThresh
        end
  
        # Returns true if the bin 4 items still need review
        def underReviewThresh
            @stats.estimate < @quiz.options.oldThresh
        end
        
        # Return a random bin (that has contents) between
        # bins *from* and *to*.  The first bin has a 50% chance
        # of being chosen.  The subsequent ones are 25%, 12.5%
        # 6.25% etc...  The last 2 bins have the same chance
        # of being chosen.  The percentages are only for bins
        # with contents.  Returns -1 if the range contains
        # no items.
        def randomBin(range)
            # If this range has no items at all, return -1
            if contents.rangeEmpty?(range)
                return -1
            end
            
            # In lisp car is the first item in the list
            # cdr is the rest of the list.  Since this is a lispish
            # algorithm, I'm using the same words.
            car = range.begin
            cdr = (range.begin + 1)..(range.end)
            
            # if one or the other of car or cdr have no items in them,
            # then return the one that has items
            if contents.rangeEmpty?(cdr)
                return car
            elsif contents.bins[car].empty?
                return randomBin(cdr)
                
            # otherwise return car 50% of the time and cdr 50% of the time
            elsif rand(2) == 0
                return car
            else
                return randomBin(cdr)
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
                    retVal = randomBin(1..3)
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
                    retVal = randomBin(1..3)
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
