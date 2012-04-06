# encoding: utf-8
require 'jldrill/model/Bin'
require 'jldrill/model/quiz/QuizItem'
require 'jldrill/model/quiz/SetStats'

module JLDrill

    # Where all the items are stored
    class QuizSet < Bin
        attr_reader :stats

        def initialize(quiz, name, number)
            super(name, number)
            @quiz = quiz
            @stats = SetStats.new(quiz, number)
        end
       
        # Just a shortcut for getting access to the options 
        def options
            @quiz.options
        end

        # Returns true if all the items in the bin have been seen
        def allSeen?
            self.all? do |item|
                item.seen?
            end
        end
        
        # Sets the schedule of each item in the bin to unseen
        def setUnseen
            self.each do |item|
                item.setAllSeen(false)
            end
        end
        
        # Returns the number of unseen items in the bin
        def numUnseen
            total = 0
            self.each do |item|
                total += 1 if !item.seen?
            end
            total
        end
        
        # Return the nth unseen item in the bin
        def findNthUnseen(n)
            retVal = nil
            if n < numUnseen
                i = 0
                0.upto(n) do |m|
                    while @contents[i].seen?
                        i += 1
                    end
                    if m != n
                        i += 1
                    end
                end
                retVal = @contents[i]
            end
            retVal
        end

        # Returns a random unseen item.
        # Resets the seen status if all the items are already seen.
        def selectRandomUnseenItem
            if allSeen?
                setUnseen
            end
            index = rand(numUnseen)
            item = findNthUnseen(index)
            return item
        end
        
        # Select an item for drilling from the set
        def selectItem
            return @contents[0]
        end

        # Do what is necessary to an item for promotion from this bin
        def promoteItem(item)
            @stats.promote(item)
        end

        # Return the number of the bin that items from this bin should be promoted to
        def promotionBin
            return @number + 1
        end

        # Return the number of the bin that items from this bin should be demoted to
        def demotionBin
            return @number - 1
        end

        # Things that should be done when a new problem has been created
        def newProblemFor(item)
            if item.bin == @number
                @stats.startTimer
            else
                @stats.stopTimer
            end
        end

        # Return a table containing the number of items that are scheduled for each
        # duration level
        def scheduleTable
            dCounter = DurationCounter.new

            @contents.each do |item|
                dCounter.count(item)
            end
            return dCounter
        end
    end
end
