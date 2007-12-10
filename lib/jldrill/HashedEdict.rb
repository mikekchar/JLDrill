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


require 'jldrill/Edict'
require 'jldrill/Vocabulary'

# Just like an Edict, only hashed on the first character of the
# reading so that we can search it faster.  Note, it's dead slow
# to iterate through the list, so don't do it if at all possible

class HashedEdict < Edict

  def initialize(file)
    super(file)
    @hash = {}
    @size = 0
  end

  def length
    return @size
  end

  def findKey(string)
    retVal = "None"
    if string
      if string =~ /^(.)/mu then retVal = $1 end
    end
    return retVal
  end

  def add(vocab)
    if vocab
      if vocab.reading
        key = findKey(vocab.reading)
        if @hash.has_key?(key)
          @hash[key].push(vocab)
        else
          @hash[key] = [vocab]
        end
        @size += 1
      end
    end
  end

  def eachVocab
    i = 0
    while i < @size
      yield(vocab(i))
      i += 1
    end
  end

  # This is invariably slow.  Avoid using it.
  def vocab(index)
    retVal = nil

    @hash.each {|key, value|
      if value
        value.each {|v|
          if v.position == index
            retVal = v
            break
          end
        }
        if(retVal)
          break
        end
      end 
    }
  end
  
  def include?(vocab)
  	if @hash
  		key = findKey(vocab.reading)
  		bin = @hash[key]
  		if bin
  			return bin.include?(vocab)
  		end
  	end
  	return false
  end

  def search(reading)
    result = []
    if @hash
      key = findKey(reading)
      bin = @hash[key]
      if bin
        bin.each { |vocab|
          if vocab.reading
            re = Regexp.new("^#{reading}")
            if re.match(vocab.reading)
              result.push(vocab)
            end
          end
        }
      end
    end

    return result
  end

end
