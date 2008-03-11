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
    class Bin
        attr_reader :name

        # Create a new bin and call it name
        def initialize(name)
            @name = name
            @contents = []
        end

        # Returns the number of vocabulary in the bin
        def length()
            return @contents.length
        end

        # Returns the vocabulary at the index specified
        def [](index)
            return @contents[index]
        end

        # Pushes a vocabulary to the end of the bin
        def push(vocab)
            @contents.push(vocab)
        end

        # Deletes the vocabulary at the specified index
        def delete_at(index)
            @contents.delete_at(index)
        end

        # Calls a block for each vocabulary in the bin
        def each(&block)
            @contents.each do |vocab|
              block.call(vocab)
            end
        end

        # Calls a block for each vocabulary in the bin, stopping if the
        # block returns false.  Returns true if all iterations return true.
        def all?(&block)
            @contents.all? do |vocab|
                block.call(vocab)
            end
        end

        # Sorts the bin according to the criteria specified in the passed in block
        def sort!(&block)
            @contents.sort! do |x,y|
              block.call(x,y)
            end
        end
   
        # Returns a string containing all the vocabulary strings in the bin     
        def to_s
            @name + "\n" + @contents.join
        end
    end
end
