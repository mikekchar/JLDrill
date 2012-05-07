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
                item.state.seen?
            end
        end
        
        # Sets the schedule of each item in the bin to unseen
        def setUnseen
            self.each do |item|
                item.state.setAllSeen(false)
            end
        end
        
        # Returns the number of unseen items in the bin
        def numUnseen
            total = 0
            self.each do |item|
                total += 1 if !item.state.seen?
            end
            total
        end
        
        # Return the nth unseen item in the bin
        def findNthUnseen(n)
            retVal = nil
            if n < numUnseen
                i = 0
                0.upto(n) do |m|
                    while @contents[i].state.seen?
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

        def correct(item)
            @stats.correct(item)
            item.state.setAllSeen(true)
        end

        def incorrect(item)
            @stats.incorrect(item)
            item.state.demote()
            # This has to be last because when the item is demoted, it
            # may add a schedule for a new problem type, which will not 
            # be seen
            item.state.setAllSeen(true)
        end

        def learn(item)
            item.state.setAllSeen(true)
            item.state.setScores(options.promoteThresh)
        end

        # Do what is necessary to an item for promotion from this bin
        def promote(item)
            @stats.promote(item)
        end

        def demote(item)
            @quiz.contents.moveToWorkingSet(item)
        end

        # Things that should be done when a new problem has been created
        def newProblemFor(item)
            # Nothing to be done here.  Override in the concrete class
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
