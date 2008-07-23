require 'jldrill/model/Quiz/Statistics'

module JLDrill

    # Strategy for a quiz
    class Strategy
        attr_reader :stats, :last
        attr_writer :last
    
        def initialize(quiz)
            @quiz = quiz
            @stats = Statistics.new
            @last = nil
        end
        
        # Returns a string showing the status of the quiz with this strategy
        def status
            if shouldReview?
                retVal = "Known: #{@stats.recentAccuracy}%"
                if @stats.inTargetZone?
                    retVal += " Conf: #{(@stats.confidence * 100).to_i}%"
                    retVal += " Left: #{(10 - @stats.timesInTargetZone)}"
                end
            else
                retVal = "New Items"
            end
            retVal
        end

        # Returns the contents (i.e. the set of vocabulary) for the quiz
        def contents
            @quiz.contents
        end

        # Returns the bin number of the new set
        def newSetBin
            0
        end
        
        # Returns true if there are no items in the new set
        def newSetEmpty?
            contents.bins[0].empty?
        end
        
        def workingSetRange
            1..3
        end
        
        # Returns a random, non-empty bin in the working set
        def workingSetBin
            randomBin(workingSetRange)
        end
        
        # Returns true if there are no items in the working set
        def workingSetEmpty?
            contents.rangeEmpty?(1..3)
        end
        
        # Returns the number of items in the working set
        def workingSetSize
            contents.bins[1].length + contents.bins[2].length + contents.bins[3].length
        end
        
        # Returns true if the working set is not full
        def workingSetFull?
             workingSetSize >= @quiz.options.introThresh
        end
        
        # returns the bin number of the review set
        def reviewSetBin
            4
        end
        
        # Returns the number of items in the review set
        def reviewSetSize
            @quiz.contents.bins[reviewSetBin].length
        end
        
        # Returns true is the working set has been
        # reviewed enough that it is considered to be
        # known.  This happens when we have reviewed
        # ten items while in the target zone.
        # The target zone occurs when in the last 10
        # items, we have a 90% success rate or when
        # we have a 90% confidence that the the items
        # have a 90% chance of success.
        def workingSetKnown?
            !(10 - @stats.timesInTargetZone > 0)        
        end
        
        # Returns true if at least one working set full of
        # items have been promoted to the review set, and
        # the review set is not known to the required
        # level.
        # Note: if the new set and the working set are
        # both empty, this will always return true.
        def shouldReview?
            # if we only have review set items, or we are in review mode
            # then return true
            if  (newSetEmpty? && workingSetEmpty?) || (@quiz.options.reviewMode)
                return true
            end
            
            !workingSetKnown? && (reviewSetSize >= @quiz.options.introThresh)
        end
        
        # Return a random bin (that has contents) in the range.
        # The first bin has a 50% chance of being chosen.  
        # The subsequent ones are 25%, 12.5%, 6.25% etc...  
        # The last 2 bins have the same chance of being chosen.
        # The percentages are only for bins with contents.  
        # Returns -1 if the range contains no items.
        def randomBin(range)
            # If this range has no items at all, return -1
            if contents.rangeEmpty?(range)
                return -1
            end
            
            # In lisp, car is the first item in the list
            # cdr is the rest of the list.  Since this is a lispish
            # algorithm, I'm using the same words.
            car = range.begin
            cdr = (range.begin + 1)..(range.end)

            # We want to avoid the bin that the last item was in,
            # thereby alternating between lesser known and
            # better known items.  First we see if the last item
            # was in cdr or car.
            inCdr = false
            inCar = false
            if !@last.nil?
                inCar = @last.status.bin == car
                inCdr = cdr.find do |x|
                    x == @last.status.bin
                end
            end
                        
            # if one or the other of car or cdr have no items in them,
            # then return the one that has items
            if contents.rangeEmpty?(cdr)
                return car
            elsif contents.bins[car].empty?
                return randomBin(cdr)
            
            # Try to avoid the last item picked, but give preference for car
            elsif inCdr
                return car
            elsif inCar
                return randomBin(cdr)
            
            # If the last item was neither in cdr or car, pick it randomly
            else
                if rand(2) == 0
                    return car
                else
                    return randomBin(cdr)
                end
            end
        end
        
        # Pick a bin that has contents.  Try to keep the working set
        # full either by reviewing items in the review set, or by
        # adding items from the new set.
        def getBin
            if contents.empty?
                return -1
            end
            
            if !workingSetFull?
                if shouldReview?
                    return reviewSetBin
                elsif !newSetEmpty?
                    return newSetBin
                end
            end
            
            return workingSetBin
        end

        def getVocabFromBin
            if contents.empty?
                return nil
            end

            if !workingSetFull?
                if shouldReview?
                    return getReviewItem
                elsif !newSetEmpty?
                    return getNewItem
                end
            end
            
            return getWorkingItem
        end
        
        # Return the index of the first item in the bin that hasn't been
        # seen yet.  If they have all been seen, reset the bin
        def findUnseen(binNum)
            bin = contents.bins[binNum]
            if bin.empty?
                return -1
            end

            if bin.allSeen?
                bin.setUnseen
            end
            bin.firstUnseen            
        end
        
        # Returns a random unseen item.  Return nil if the range is empty.
        # Resets the seen status if all the items are already seen.
        def randomUnseen(range)
            if contents.rangeEmpty?(range)
                return nil
            end
            if contents.rangeAllSeen?(range)
                range.to_a.each do |bin|
                    contents.bins[bin].setUnseen
                end
            end
            index = rand(contents.numUnseen(range))
            vocab = contents.findUnseen(index, range)
            vocab
        end
        
        def getNewItem
            if @quiz.options.randomOrder
                index = rand(contents.bins[newSetBin].length)
            else
                index = findUnseen(newSetBin)
            end
            if !(index == -1)
                vocab = contents.bins[newSetBin][index]
                promote(vocab)
                vocab
            else
                nil
            end
        end
        
        def getReviewItem
            index = findUnseen(reviewSetBin)
            if !(index == -1)
                contents.bins[reviewSetBin][index]
            else
                nil
            end
        end
        
        def getWorkingItem
            randomUnseen(workingSetRange)
        end
        
        def getVocab
            vocab = getVocabFromBin
            if vocab.nil?
                return nil
            end

            vocab.status.seen = true
            @last = vocab 
            return vocab
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
                    if vocab.status.bin == 4
                        # Reset the number of times incorrect when demoting
                        # back into the working set
                        vocab.status.numIncorrect = 0
                    end
                    moveToBin(vocab, 1)
                else
                	# Demoting bin 0 items is non-sensical, but it should do
	                # something sensible anyway.
                    moveToBin(vocab, 0)
                end
            end
        end

        def collectStatistics(vocab, good)
            if(vocab.status.bin == 4)
                if(good)
                    @stats.correct(vocab)
                else
                    @stats.incorrect(vocab)
                end
            end
        end
  
        def correct
            vocab = @quiz.currentProblem.vocab
            collectStatistics(vocab, true)
            if(vocab)
                vocab.status.schedule
                vocab.status.markReviewed
                vocab.status.score += 1
                if(vocab.status.score >= @quiz.options.promoteThresh)
                    vocab.status.score = 0
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
            collectStatistics(vocab, false)
            if(vocab)
                vocab.status.unschedule
                vocab.status.markReviewed
                vocab.status.score = 0
                vocab.status.incorrect
                demote(@quiz.currentProblem.vocab)
                vocab.status.consecutive = 0
                @quiz.update
            end
        end
    end
end
