require 'jldrill/model/Bin'

module JLDrill

    # Where all the items are stored
    class Contents

        LINE_START_RE =  /^\//

        attr_reader :quiz, :bins
    
        def initialize(quiz)
            @quiz = quiz
            @bins = []
            @res = []
            addBin("Unseen")
            addBin("Poor")
            addBin("Fair")
            addBin("Good")
            addBin("Excellent")
            @binNum = 0
        end

        # Returns true if the contents have been changed but not saved
        def saveNeeded
            @quiz.setNeedsSave(true)
        end

        def itemAdded(item)
            @quiz.updateItemAdded(item)
        end
        
        # Adds a new bin to the end of the contents
        def addBin(name)
            @bins.push(Bin.new(name, @bins.length))
            @res.push(Regexp.new("^#{name}$"))
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

        # Add an item to a bin
        def addItem(item, bin)
            item.bin = bin
            item.quiz = @quiz
            item.schedule.score = 0
            if item.position == -1
                item.position = length 
            end
            @bins[bin].push(item)
            item.container = self
            itemAdded(item)
            saveNeeded
        end

        # Adds a vocab to a specific bin. Returns the item that was added
        def add(vocab, bin)
            item = nil
            if !vocab.nil? && vocab.valid?
                item = Item.new(vocab)
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
                item.position = -1
                addItem(item, item.bin)
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
                    newItem.position = -1
                    self.addItem(newItem, newItem.bin)
                    lastItem = newItem
                end
            end
            return lastItem
        end

        # Parse the line for an item.  
        # Add it to the contents in the specified bin.
        # Return the item that was added.
        def parseItem(line, bin)
            item = Item.create(line)
            return addItem(item, bin)
        end

        def parseLine(line)
            parsed = false
            # Line items are the most common, so they are checked first
            if line =~ LINE_START_RE
                    parseItem(line, @binNum)
                    parsed = true
            else
                # Bin names are less common so they are checked after
                @bins.each do |bin|
                    re = @res[bin.number]
                    if line =~ re
                        @binNum = bin.number
                        parsed = true
                    end
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
                x.position <=> y.position
            end
            # Renumber the positions in case they are out of whack
            i = 0
            items.each do |item|
                item.position = i
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
                item.schedule.reset
                item.itemStats.reset
            end
            saveNeeded
        end

        # Move the specified item to the specified bin
        def moveToBin(item, bin)
            if !item.nil?
                @bins[item.bin].delete(item)
                @bins[bin].push(item)
                saveNeeded
            end
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
                @bins[item.bin].delete(item)
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
                    print "#{item.position}: #{item.to_o.reading}..."
                    duplicates = self.findAll do |candidate|
                        ((item != candidate) && (obj == candidate.to_o))
                    end
                    duplicates.each do |dup|
                        print "   #{dup.position}"
                        self.delete(dup)
                    end
                    print "\n"
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
        
        # Returns the number of unseen items in the range of bins
        def numUnseen(range)
            total = 0
            range.each do |i|
                total += @bins[i].numUnseen
            end
            total
        end
        
        # returns true if there are bins in the specified range
        def includesRange?(range)
            !(range.begin < 0 || range.end > 4)
        end
        
        # Returns the nth unseen item in the range of contents, or nil if there
        # aren't any unseen items
        def findUnseen(n, range)
            total = numUnseen(range)
            if n > total || !includesRange?(range)
                return nil
            end
            
            i = range.end
            prev = total
            while (prev = (prev - @bins[i].numUnseen)) > n
                i -= 1 
            end
            
            @bins[i].findUnseen(n - prev)
        end

        # Returns false if any of the bins in the range have
        # unseen items in them
        def rangeAllSeen?(range)
            a = range.to_a
            seen = a.all? do |bin|
                @bins[bin].allSeen?
            end
            seen
        end

        # Returns false if any of the bins in the range have
        # items in them
        def rangeEmpty?(range)
            a = range.to_a
            hasItems = a.any? do |bin|
                !@bins[bin].empty?
            end
            !hasItems
        end
        
        # Return a string containing the length of all the bins
        def status
            retVal = "New: #{@bins[0].length} "
            retVal += "Review: #{@bins[4].length} "
            retVal += "Working: #{@bins[1].length}, "
            retVal += "#{@bins[2].length}, "
            retVal += "#{@bins[3].length}"
            retVal
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

