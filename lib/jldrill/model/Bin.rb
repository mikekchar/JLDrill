# encoding: utf-8
module JLDrill
    # Holds a group of items that are at the same level.
    class Bin
        attr_reader :name, :number, :contents

        # Create a new bin and call it name
        def initialize(name, number)
            @name = name
            @number = number
            @contents = []
            @nameRegExps = []
            addAlias(@name)
        end

        # Add a name that this bin might be called when parsing a file
        def addAlias(name)
            @nameRegExps.push(Regexp.new("^#{name}$", nil))
        end

        # add an array of aliases
        def addAliases(aliasList)
            aliasList.each do |name|
                addAlias(name)
            end
        end

        # Returns true if the bin is named or has an alias for
        # the string passed
        def isCalled?(name)
            return @nameRegExps.any? do |re|
                re.match(name)
            end
        end

        # Returns the number of items in the bin
        def length()
            return @contents.length
        end

        # Returns the number of items in the bin
        def size()
            return @contents.size
        end

        # Returns the item at the index specified
        def [](index)
            item = @contents[index]
            return item
        end

        def last
            if length > 0
                item = @contents[length - 1]
                return item
            else
                return nil
            end
        end

        # Pushes a item to the end of the bin
        # Also sets the bin number of the item
        def push(item)
            item.state.moveTo(@number)
            @contents.push(item)
        end

        # Insert an item before the index indicated
        def insert(index, item)
            item.state.moveTo(@number)
            if index >= @contents.size
                @contents.push(item)
            else
                @contents.insert(index, item)
            end
        end

        def moveBeforeItem(moveItem, beforeItem)
            index = @contents.find_index(beforeItem)
            if !index.nil?
                delete(moveItem)
                insert(index, moveItem)
            end
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
            insert(i, item)
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

        # Calls a block for each item in the bin in the reverse order
        def reverse_each(&block)
            @contents.reverse_each do |item|
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

        # Sorts the bin according to the criteria specified in the 
        # passed in block
        def sort!(&block)
            @contents.sort! do |x,y|
              block.call(x,y)
            end
        end

        # Returns an array of items for which block returns true
        def find_all(&block)
            retVal = []
            @contents.each do |item|
                if block.call(item)
                    retVal.push(item)
                end
            end
            return retVal
        end

        # Set the contents array to the value specified.  Also set the bin
        # number correctly
        def contents=(array)
            @contents = array
            self.each do |item|
                item.state.moveTo(@number)
            end
        end
   
        # Returns true if the bin is empty
        def empty?
            @contents.empty?
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
