require 'jldrill/model/Bin'

module JLDrill

    # Where all the items are stored
    class Contents
        attr_reader :quiz, :bins
    
        def initialize(quiz)
            @quiz = quiz
            @bins = []
            addBin("Unseen")
            addBin("Poor")
            addBin("Fair")
            addBin("Good")
            addBin("Excellent")
            @parsingBin = 0
        end

        # Returns true if the contents have been changed but not saved
        def saveNeeded
            @quiz.setNeedsSave(true)
        end
        
        # Adds a new bin to the end of the contents
        def addBin(name)
            @bins.push(Bin.new(name, @bins.length))
        end
        
        # Returns the number items in all the bins
        def length
            total = 0
            @bins.each do |bin|
                total += bin.length
            end
            total
        end

        # Add an item to a bin
        def addItem(item, bin)
            item.status.score = 0
            if item.status.position == -1
                item.status.position = length 
            end
            @bins[bin].push(item)
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
            @bins.any? do |bin|
                bin.contain?(vocab)
            end
        end
        
        # Adds an item to the contents only if it doesn't already
        # exist.  It places it in the bin specified in the item.  It
        # also sets it's position to the end contents.
        def addUniquely(item)
            if !exists?(item.to_o)
                item.status.position = -1
                addItem(item, item.status.bin)
                true
            else
                false
            end
        end

        # Goes through each of the items in the contents by position.
        # This is going to be very slow, so don't use it unless you
        # really have to.
        def eachByPosition(&block)
            tempArray = []
            @bins.each do |bin|
                bin.each do |item|
                    tempArray.push(item)
                end
            end
            tempArray.sort! do |x, y|
                x.status.position <=> y.status.position
            end
            tempArray.each(&block)
        end
        
        # Add the contents from another quiz to this one.  Only
        # adds the items that doen't already exists.  Sets the positions
        # of the new items to the end of this contents.
        def addContents(contents)
            contents.eachByPosition do |item|
                self.addUniquely(item.clone)
            end
        end

        # Parse the line for an item.  Add it to the contents.
        # Return the item that was added.
        def parseItem(line)
            item = Item.create(line)
            return addItem(item, @parsingBin)
        end

        def parseLine(line)
            parsed = false
            @bins.each do |bin|
                re = Regexp.new("^#{bin.name}$")
                if line =~ re
                    @parsingBin = bin.number
                    parsed = true
                end
            end
            if line =~ /^\// 
                    parseItem(line)
                    parsed = true
            end
            parsed
        end

        # Return an array of all the vocab in the bins
        def allVocab
            retVal = []
            bins.each do |bin|
                bin.contents.each do |item|
                    retVal.push(item.to_o)
                end
            end
            retVal
        end

        # Reset the contents back to their original order and status
        def reset
            1.upto(@bins.length - 1) do |i|
                @bins[0].contents += @bins[i].contents
                @bins[i].contents = []
            end
            @bins[0].each do |item|
                item.status.reset
            end
            @bins[0].sort! { |x,y| x.status.position <=> y.status.position }
            saveNeeded
        end

        # Move the specified item to the specified bin
        def moveToBin(item, bin)
            if !item.nil?
                @bins[item.status.bin].delete_at(item.status.index)
                @bins[bin].push(item)
                saveNeeded
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
            overdue = @bins[4].numOverdue
            if overdue != 0
                retVal += " Behind: #{overdue}"
            end
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

