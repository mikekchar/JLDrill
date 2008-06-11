#    JLDrill - A program to drill various aspects of the Japanese Language
#    Copyright (C) 2005  Mike Charlton
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


module JLDrill
    # Holds a group of vocabulary items that are at the same level.
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

        # Returns the number of vocabulary in the bin
        def length()
            return @contents.length
        end

        # Returns the vocabulary at the index specified
        def [](index)
            vocab = @contents[index]
            vocab.status.index = index unless vocab.nil?
            vocab
        end

        # Pushes a vocabulary to the end of the bin
        # Also sets the bin number of the vocab
        def push(vocab)
            vocab.status.bin = @number
            vocab.status.index = @contents.length
            @contents.push(vocab)
        end

        # Deletes the vocabulary at the specified index
        def delete_at(index)
            @contents[index].status.index = nil unless @contents[index].nil?
            @contents.delete_at(index)
            index.upto(@contents.length - 1) do |i|
                @contents[i].status.index = i
            end
        end

        # Calls a block for each vocabulary in the bin
        def each(&block)
            i = 0
            @contents.each do |vocab|
                vocab.status.index = i
                i += 1
                block.call(vocab)
            end
        end

        # Calls a block for each vocabulary in the bin, stopping if the
        # block returns false.  Returns true if all iterations return true.
        def all?(&block)
            i = 0
            @contents.all? do |vocab|
                vocab.status.index = i
                i += 1
                block.call(vocab)
            end
        end

        # Update the indeces of all the vocab entries in the bin.
        def updateIndeces
            # each() already updates it, so all we have to do it reference them
            self.each do |vocab|
            end
        end

        # Sorts the bin according to the criteria specified in the passed in block
        def sort!(&block)
            @contents.sort! do |x,y|
              block.call(x,y)
            end
            updateIndeces
        end
   
        # Make a copy of the contents.  Note that the items in the contents are
        # *the same* objects.  It's only the array which is new.
        def cloneContents
            Array.new(@contents)
        end
   
        # Set the contents array to the value specified.  Also set the bin
        # number correctly
        def contents=(array)
            @contents = array
            # This will also update the indeces
            self.each do |vocab|
                vocab.status.bin = @number
            end
        end
   
        # Returns true if the bin is empty
        def empty?
            @contents.empty?
        end

        # Returns the number of unseen items in the bin
        def numUnseen
            total = 0
            @contents.each do |vocab|
                total += 1 if !vocab.status.seen
            end
            total
        end
        
        # Returns true if all the items in the bin have been seen
        def allSeen?
            @contents.all? do |vocab|
                vocab.status.seen?
            end
        end
        
        # Return the index of the first item in the bin that hasn't been
        # seen yet.  Returns -1 if there are no unseen items
        def firstUnseen
            index = 0
            # find the first one that hasn't been seen yet
            while (index < length) && @contents[index].status.seen?
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
                    while @contents[i].status.seen
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

        # Sets the status of each item in the been to unseen
        def setUnseen
            @contents.each do |vocab|
                vocab.status.seen = false
            end
        end

        # Returns a string containing all the vocabulary strings in the bin     
        def to_s
            @name + "\n" + @contents.join
        end
    end
end
