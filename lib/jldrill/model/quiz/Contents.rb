# encoding: utf-8
require 'jldrill/model/Bin'
require 'jldrill/model/quiz/QuizItem'
require 'jldrill/model/quiz/NewSet'
require 'jldrill/model/quiz/WorkingSet'
require 'jldrill/model/quiz/ReviewSet'
require 'jldrill/model/quiz/ForgottenSet'
require 'jldrill/model/quiz/ContentStats'

module JLDrill

    # Where all the items are stored
    class Contents

        LINE_START_RE =  /^\//

        attr_reader :quiz, :bins, :stats,
                    :newSetBin, :workingSetBin, :reviewSetBin, :forgottenSetBin
    
        def initialize(quiz)
            @quiz = quiz
            @bins = []
            @newSetBin = addSetType(NewSet)
            @workingSetBin = addSetType(WorkingSet)
            @reviewSetBin = addSetType(ReviewSet)
            @forgottenSetBin = addSetType(ForgottenSet)
            @stats = ContentStats.new(self)
            @binNum = 0
        end

        def options
            @quiz.options
        end

        # Adds a set to the bins array and returns its position
        def addSetType(setType)
            binNumber = @bins.size
            @bins.push(setType.new(@quiz, binNumber))
            return binNumber
        end

        def newSet
            return @bins[@newSetBin]
        end

        def workingSet
            return @bins[@workingSetBin]
        end

        def reviewSet
            return @bins[@reviewSetBin]
        end

        def forgottenSet
            return @bins[@forgottenSetBin]
        end

        # Returns true if the contents have been changed but not saved
        def saveNeeded
            @quiz.setNeedsSave(true)
        end

        def itemAdded(item)
            @quiz.updateItemAdded(item)
        end
        
        # Adds a new bin to the end of the contents
        def addBin(name, *aliases)
            bin = Bin.new(name, @bins.length)
            bin.addAliases(aliases)
            @bins.push(bin)
        end
        
        # Returns the number items in all the bins
        def length
            total = 0
            @bins.each do |bin|
                total += bin.length
            end
            total
        end

        def size
            length
        end

        # Push an item to the back of a bin.  This should only be
        # called by local member functions
        def pushItem(item, bin)
            item.quiz = @quiz
            item.state.quiz = @quiz
            if item.state.position == -1
                item.state.reposition(length())
            end
            @bins[bin].push(item)
            item.state.updateSchedules
        end

        # Add an item to a bin
        def addItem(item, bin)
            pushItem(item, bin)
            itemAdded(item)
            saveNeeded
        end

        # Adds a vocab to a specific bin. Returns the item that was added
        def add(vocab, bin)
            item = nil
            if !vocab.nil? && vocab.valid?
                item = QuizItem.new(@quiz, vocab)
                addItem(item, bin)
            end
            return item
        end
        
        # Returns true if the vocabulary exists already in the contents
        def exists?(vocab)
            return @bins.any? do |bin|
                bin.contain?(vocab)
            end
        end

        # Adds an item to the contents only if it doesn't already
        # exist.  It places it in the bin specified in the item.  It
        # also sets it's position to the end contents.
        def addUniquely(item)
            if !exists?(item.to_o)
                item.state.reposition(-1)
                addItem(item, item.state.bin)
                true
            else
                false
            end
        end

        # Goes through each of the items in the contents by position.
        # This is going to be very slow, so don't use it unless you
        # really have to.
        def eachByPosition(&block)
            tempArray = allItems
            tempArray.each(&block)
        end
        
        # swap the positions between two items
        # If they are both in the new bin, actually swap them
        def swapWith(item1, item2)
            temp = item1.state.position
            item1.state.reposition(item2.state.position)
            item2.state.reposition(temp)
           
            if !@quiz.nil?
                if (item1.state.bin == 0) && (item2.state.bin == 0)
                    @quiz.contents.bins[item1.state.bin].moveBeforeItem(item1, item2)
                end
                @quiz.setNeedsSave(true)
            end
        end

        # Change the position of item1 to be before item2.
        # If both items are in the new set, actually move item2
        # so that it is before item2.
        def insertBefore(item1, item2)
            target = item2.state.position
            # This is clearly slow. It can be made slightly
            # faster by only iterating over the relevant
            # items, but I don't know if it's worth the effort
            # since the majority of the cost is in creating the
            # sorted array in the first place.
            eachByPosition do |i|
                if (i.state.position >= target) &&
                        (i.state.position < item1.state.position)
                    i.state.reposition(i.state.position + 1)
                end
            end
            item1.state.reposition(target)

            if !@quiz.nil?
                # If they are both in the new set actually move the item
                if (item1.state.bin == 0) && (item2.state.bin == 0)
                    @quiz.contents.bins[item1.state.bin].moveBeforeItem(item1, item2)
                end
                @quiz.setNeedsSave(true)
            end
        end

        # Get an array of all the items sorted by hash.
        # The array includes a binary search algorithm for finding
        # items.
        def getSortedItems
            items = []
            bins.each do |bin|
                items += bin.contents
            end
            items = allItems.sort! do |x, y|
                x.hash <=> y.hash
            end
            def items.binarySearch(item, spos=nil, epos=nil)
                if spos == nil
                    spos = 0
                end
                if epos == nil
                    epos = self.size - 1
                end
                if spos > epos
                    return false
                end
                pos = ((epos - spos) / 2) + spos
                if self[pos].hash < item.hash
                    return self.binarySearch(item, pos + 1, epos)
                elsif self[pos].hash > item.hash
                    return self.binarySearch(item, spos, pos - 1)
                else
                    return self[pos].eql?(item)
                end
            end
            return items
        end            

        # Add the contents from another quiz to this one.  Only
        # adds the items that doen't already exists.  Sets the positions
        # of the new items to the end of this contents.
        # Returns the last item that was added, or nil if none were added.
        def addContents(contents)
            lastItem = nil
            tempArray = getSortedItems
            contents.eachByPosition do |item|
                if !tempArray.binarySearch(item)
                    newItem = item.clone
                    newItem.state.reposition(-1)
                    self.addItem(newItem, newItem.state.bin)
                    lastItem = newItem
                end
            end
            return lastItem
        end

        # Parse the line for an item.  
        # Add it to the contents in the specified bin.
        # Return the item that was added.
        def parseItem(line, bin)
            item = QuizItem.create(@quiz, line, bin)
            return addItem(item, bin)
        end

        def binNumFromName(name)
            retVal = -1
            myBin = @bins.find do |bin|
                bin.isCalled?(name)
            end
            retVal = myBin.number unless myBin.nil?
            return retVal
        end

        def parseLine(line)
            parsed = false
            # Line items are the most common, so they are checked first
            if line =~ LINE_START_RE
                    parseItem(line, @binNum)
                    parsed = true
            else
                # Bin names are less common so they are checked after
                num = binNumFromName(line)
                if num != -1 
                   @binNum = num 
                   parsed = true
                end
            end
            parsed
        end

        # Returns an array of all the items in the bins, sorted by
        # position.  Note: this also updates the positions of the
        # items if they are out of whack (i.e. duplicates).  This
        # is to combat against some old broken files.
        def allItems
            items = []
            bins.each do |bin|
                items += bin.contents
            end
            items.sort! do |x,y| 
                x.state.position <=> y.state.position
            end
            # Renumber the positions in case they are out of whack
            i = 0
            items.each do |item|
                item.state.reposition(i)
                i += 1
            end
            return items
        end

        # Reset the contents back to their original order and schedule
        def reset
            @bins[0].contents = allItems
            1.upto(@bins.length - 1) do |i|
                @bins[i].contents = []
            end
            @bins[0].each do |item|
                item.state.allReset
            end
            saveNeeded
        end

        # Move the specified item to the specified bin
        def moveToBin(item, bin)
            if !item.nil?
                @bins[item.state.bin].delete(item)
                pushItem(item, bin)
                saveNeeded
            end
        end

        def moveToNewSet(item)
            moveToBin(item, newSetBin)
        end

        def moveToWorkingSet(item)
            moveToBin(item, workingSetBin)
        end

        def moveToReviewSet(item)
            moveToBin(item, reviewSetBin)
        end

        def moveToForgottenSet(item)
            moveToBin(item, forgottenSetBin)
        end

        # Renumber the positions of the items
        def repositionItems
            # allItems renumbers the positions as a side-effect.
            # Perhaps I should duplicate the code here.  I'm of
            # two minds...
            allItems
        end

        # Delete the specified item
        def delete(item)
            if !item.nil?
                @bins[item.state.bin].delete(item)
                repositionItems
                saveNeeded
            end
        end

        # Returns a list of items for which block returns true
        def findAll(&block)
            retVal = []
            @bins.each do |bin|
                retVal += bin.findAll(&block)
            end
            return retVal
        end

        # Removes all duplicate items.  Keeps the version in the
        # highest bin
        def removeDuplicates
            @bins.reverse_each do |bin|
                bin.reverse_each do |item|
                    obj = item.to_o
                    duplicates = self.findAll do |candidate|
                        ((item != candidate) && (obj == candidate.to_o))
                    end
                    duplicates.each do |dup|
                        self.delete(dup)
                    end
                end
            end
        end

        # Returns true if all of the bins are empty
        def empty?
            retVal = @bins.all? do |bin|
                bin.empty?
            end
            retVal
        end
        
        # Return the number of items in the bin that are of level, level
        def numLevel(bin, level)
            retVal = 0
            @bins[bin].each do |item|
                if (item.state.level == level)
                    retVal += 1
                end
            end
            return retVal
        end

        # Go through each of the bins and make sure the schedules
        # are set correctly for each item.  It is usually done when the
        # options change.
        def updateSchedules
            @bins.each do |bin|
                bin.each do |item|
                    item.state.updateSchedules
                end
            end
        end

        # Sort the items according to their schedule
        def reschedule
            reviewSet.removeInvalidKanjiProblems
            reviewSet.forgetItems
            forgottenSet.rememberItems
            reviewSet.reschedule
            forgottenSet.reschedule
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
            if  (newSet.empty? && workingSet.empty?) || options.reviewMode
                return true
            else
                return reviewSet.shouldReview?
            end
        end

        # Get an item from the New Set
        # Note: It promotes that item to the working set in the process
        def getNewItem
            item = newSet.selectItem()
            if !item.nil?
                item.state.promote
            end
            return item
        end
        
        # Get an item to quiz
        def getItem
            item = nil

            if !workingSet.full?
                if shouldReview?
                    item = reviewSet.selectItem()
                elsif !forgottenSet.empty?
                    item = forgottenSet.selectItem()
                elsif !newSet.empty?
                    item = getNewItem
                end
            end

            # Usually we get a working item if the above is not true
            item = workingSet.selectItem() if item.nil?

            item.state.setAllSeen(true) if !item.nil?
            return item
        end

        # Notify each bin that a new problem has been created
        def newProblemFor(item)
            @bins.each do |bin|
                bin.newProblemFor(item)
            end
        end

        # Returns a string showing the status kinds of items we are selecting
        def selectionStatus
            if shouldReview?
                return @stats.reviewStatus
            elsif !forgottenSet.empty?
                return " Forgotten Items"
            else
                return "     New Items"
            end
        end

        def newStatus
            return "New: #{@bins[0].length} "
        end

        def forgottenStatus
            retVal = ""
            if (options.forgettingThresh != 0.0)
                retVal = "Forgotten: #{@bins[3].length} "
            end
            return retVal
        end

        def reviewStatus
            return "Review: #{@bins[2].length} "
        end

        def workingStatus
            return "Working: #{self.numLevel(1,0)}, #{self.numLevel(1,1)}, #{self.numLevel(1,2)}"
        end
        
        # Return a string containing the length of all the bins
        def status
            retVal = newStatus()
            retVal += forgottenStatus()
            retVal += reviewStatus()
            retVal += workingStatus()
            return retVal
        end
        
        def to_s
            retVal = ""
            @bins.each do |bin|
                retVal += bin.to_s
            end
            retVal
        end
        
    end
end    

