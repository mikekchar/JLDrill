module JLDrill
    # Holds a group of items that are at the same level.
    # Note that the index of the item is updated when the item is *referenced*
    # from the bin using []  Therefore DO NOT reference
    # the contents directly using @contents!!!
    class Bin
        attr_reader :name, :number, :contents

        # Create a new bin and call it name
        def initialize(name, number)
            @name = name
            @number = number
            @contents = []
        end

        # Returns the number of items in the bin
        def length()
            return @contents.length
        end

        # Returns the item at the index specified
        def [](index)
            item = @contents[index]
            item.index = index unless item.nil?
            item
        end

        # Pushes a item to the end of the bin
        # Also sets the bin number of the item
        def push(item)
            item.bin = @number
            item.index = @contents.length
            @contents.push(item)
        end
        
        # Deletes the item at the specified index
        def delete_at(index)
            @contents[index].index = nil unless @contents[index].nil?
            @contents.delete_at(index)
            index.upto(@contents.length - 1) do |i|
                @contents[i].index = i
            end
        end

        # Calls a block for each item in the bin
        def each(&block)
            i = 0
            @contents.each do |item|
                item.index = i
                i += 1
                block.call(item)
            end
        end

        # Calls a block for each item in the bin, stopping if the
        # block returns false.  Returns true if all iterations return true.
        def all?(&block)
            i = 0
            @contents.all? do |item|
                item.index = i
                i += 1
                block.call(item)
            end
        end

        # Update the indeces of all the item entries in the bin.
        def updateIndeces
            # each() already updates it, so all we have to do it reference them
            self.each do |item|
            end
        end

        # Sorts the bin according to the criteria specified in the passed in block
        def sort!(&block)
            @contents.sort! do |x,y|
              block.call(x,y)
            end
            updateIndeces
        end
   
        # Set the contents array to the value specified.  Also set the bin
        # number correctly
        def contents=(array)
            @contents = array
            # This will also update the indeces
            self.each do |item|
                item.bin = @number
            end
        end
   
        # Returns true if the bin is empty
        def empty?
            @contents.empty?
        end

        # Returns the number of unseen items in the bin
        def numUnseen
            total = 0
            @contents.each do |item|
                total += 1 if !item.schedule.seen
            end
            total
        end
        
        # Returns true if all the items in the bin have been seen
        def allSeen?
            @contents.all? do |item|
                item.schedule.seen?
            end
        end
        
        # Return the index of the first item in the bin that hasn't been
        # seen yet.  Returns -1 if there are no unseen items
        def firstUnseen
            index = 0
            # find the first one that hasn't been seen yet
            while (index < length) && @contents[index].schedule.seen?
                index += 1
            end
            
            if index >= length
                index = -1
            end
            index
        end
        
        # Return the nth unseen item in the bin
        def findUnseen(n)
            retVal = nil
            if n < numUnseen
                i = 0
                0.upto(n) do |m|
                    while @contents[i].schedule.seen
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

        # Sets the schedule of each item in the bin to unseen
        def setUnseen
            @contents.each do |item|
                item.schedule.seen = false
            end
        end
        
        # Returns the number of days the "now" for scheduled
        # items are skewed from the real now.  Positive numbers
        # are in the future, negative numbers in the past.
        # rounds to the nearest tenth.
        def dateSkew
            skew = 0.0
            if @contents.size > 0 && !@contents[0].nil?
                skew = @contents[0].schedule.dateSkew
            end
            return skew
        end
        
        def numScheduledOn(day)
            total = 0
            @contents.each do |item|
                if item.schedule.scheduledOn?(day)
                    total += 1
                end
            end
            total
        end
        
        def numDurationWithin(range)
            total = 0
            @contents.each do |item|
                if item.schedule.durationWithin?(range)
                    total += 1
                end
            end
            total
        end

        # Returns true if the Item exists in the bin
        def exists?(item)
            !@contents.find do |x|
                item.eql?(x)
            end.nil?
        end

        # Returns true if there is an Item in the bin that contains the object
        def contain?(object)
            !@contents.find do |x|
                x.contain?(object)
            end.nil?
        end

        # Returns a string containing all the item strings in the bin     
        def to_s
            @name + "\n" + @contents.join
        end
    end
end
