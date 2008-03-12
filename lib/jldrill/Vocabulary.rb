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


require "jldrill/VocabularyStatus"

# Class file for Japanese vocabulary
# Currently geared towards edict, but that might change

class Vocabulary

      KANJI_RE = /^Kanji: (.*)/
      HINT_RE = /^Hint: (.*)/
      READING_RE = /^Reading: (.*)/
      DEFINITIONS_RE = /^Definitions: (.*)/
      MARKERS_RE = /^Markers: (.*)/

  attr_reader :kanji, :reading, :hint, :status
  attr_writer :kanji, :reading, :hint

  def initialize
    @kanji = nil
    @reading = nil
    @definitions = nil
    @markers = nil
    @hint = nil
    @status = JLDrill::VocabularyStatus.new(self)
  end
  
  # Create a new vocaublary item by parsing the string passed in.
  def Vocabulary.create(string)
    retVal = Vocabulary.new
    retVal.parse(string)
    retVal
  end

  # True if the two vocabulary are discussing the same word
  # This does *not* compare the hint, score, or position
  # since they do not affect the meaning of the word.
  def eql?(y)
    retVal = false
    if y != nil
      retVal = true
      retVal &= @kanji == y.kanji
      retVal &= @reading == y.reading
      retVal &= self.definitions == y.definitions
      retVal &= self.markers == y.markers
    end
    return retVal
  end

  # True if the two vocabulary are discussing the same word
  # This does *not* compare the hint, score, or position
  # since they do not affect the meaning of the word.
  def ==(y)
    return eql?(y)
  end
  
  # splits the string on commas and destroys and leading space
  def Vocabulary.splitCommas(string)
    array = string.split(",")
    array.each do |item|
        item.strip!
    end
    array
  end
  
  # Join the array into a string with ", " in between each item.
  # if the array is empty or nil, print ""
  def Vocabulary.joinCommas(array)
    if !array.nil?
      return array.join(", ")
    else
      return ""
    end
  end
  
  # Returns a string containing the definitions separated
  # by commas
  def definitions
    Vocabulary.joinCommas(@definitions)    
  end

  # Assigns the definitions from a string of comma separated
  # definitions
  def definitions=(string)
    @definitions = Vocabulary.splitCommas(string)
  end

  # Returns a string containing the markers separated
  # by commas
  def markers
    Vocabulary.joinCommas(@markers)    
  end

  # Returns a string containing the markers separated
  # by commas
  def markers=(string)
    @markers = Vocabulary.splitCommas(string)
  end

  # Returns true if the vocabulary contains at least one
  # definition and a reading
  def valid?
    return (!@definitions.nil? && (@definitions.length > 0) && !@reading.nil?)
  end

  # Parses a vocabulary value in save format.
  def parse(string)
    string.split("/").each do |part|
      case part
        when KANJI_RE
          @kanji = $1
        when HINT_RE 
          @hint = $1
        when READING_RE 
          @reading = $1
        when DEFINITIONS_RE 
          self.definitions = $1
        when MARKERS_RE
          self.markers = $1
        else # Maybe it's the status, if not ignore it
          @status.parse(part)
      end
    end
  end

  # Outputs to tab separated values.  This is primarily for
  # outputing the data for other quiz programs.  There are only 3 fields.
  # kanji    reading    (markers) definitions
  # The markers and definitions are merged into one field.
  def to_tsv
    retVal = ""
    if @kanji
      retVal += @kanji
    end
    retVal += "\t" + @reading + "\t(" + markers + ") " + definitions
    return retVal
  end

  # Output the vocabulary as a string in save file format
  def to_s
    retVal = ""
    if @kanji
      retVal += "/Kanji: #{@kanji}"
    end

    if @hint
      retVal += "/Hint: #{@hint}"
    end

    retVal += "/Reading: #{@reading}"
    retVal += "/Definitions: #{@definitions.join(",")}"

    if @markers && (not @markers.empty?)
      retVal += "/Markers: #{@markers.join(",")}"
    end
    
    retVal += @status.to_s
    
    retVal += "/\n"

    return retVal
  end

end
