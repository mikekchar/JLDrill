module JLDrill
    # Holds a group of items that are at the same level.
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
            return item
        end

        # Pushes a item to the end of the bin
        # Also sets the bin number of the item
        def push(item)
            item.bin = @number
            @contents.push(item)
        end

        # Insert an item before the index indicated
        def insertAt(index, item)
            if index >= @contents.size
                @contents.push(item)
            else
                @contents.insert(index, item)
            end
            item.bin = @number
        end

        # Inserts an item before the one where
        # the block evaluates true.  If the block
        # never evaluates true, put the item at
        # the end
        def insertBefore(item, &block)
            i = 0
            while(!contents[i].nil? && !block.call(i))
                i += 1
            end
            insertAt(i, item)
        end
        
        def delete(item)
            @contents.delete(item)
        end

        # Calls a block for each item in the bin
        def each(&block)
            @contents.each do |item|
                block.call(item)
            end
        end

        # Calls a block for each item in the bin, stopping if the
        # block returns false.  Returns true if all iterations return true.
        def all?(&block)
            @contents.all? do |item|
                block.call(item)
            end
        end

        # Sorts the bin according to the criteria specified in the passed in block
        def sort!(&block)
            @contents.sort! do |x,y|
              block.call(x,y)
            end
        end
   
        # Set the contents array to the value specified.  Also set the bin
        # number correctly
        def contents=(array)
            @contents = array
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
        
        # Find the scheduledTime for the first item in the bin.
        # Return now if the first item isn't scheduled
        def firstSchedule
            retVal = Time::now
            if @contents.size > 0
                first = @contents[0]
                if !first.nil? && first.schedule.scheduled?
                    retVal = first.schedule.scheduledTime
                end
            end
            return retVal
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
