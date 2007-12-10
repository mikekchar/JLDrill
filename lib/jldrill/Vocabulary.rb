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


# Class file for Japanese vocabulary
# Currently geared towards edict, but that might change

class Vocabulary

  attr_reader :kanji, :reading, :hint, :score, :bin, :level, :position
  attr_writer :kanji, :reading, :hint, :score, :bin, :level, :position

  def initialize(kanji=nil, reading=nil, 
                 definitions=nil, markers=nil, hint=nil, position=-1)
    @kanji = kanji
    @reading = reading
    @definitions = definitions
    @markers = markers
    @hint = hint
    @score = 0
    @bin = 0
    @level = 0
    @position = position
  end

  def set(vocab)
    @kanji = vocab.kanji
    @reading = vocab.reading
    self.definitions = vocab.definitions
    self.markers = vocab.markers
    @hint = vocab.hint
    @score = vocab.score
    @bin = vocab.bin
    @level = vocab.level
    @position = vocab.position
    if @kanji && (@kanji == "") then @kanji = nil end
    if @reading && (@reading == "") then @reading = nil end
    if @hint && (@hint == "") then @hint = nil end
  end

  def eql?(y)
    retVal = false
    if y != nil
      retVal = true
      retVal &= @kanji == y.kanji
      retVal &= @reading == y.reading
      retVal &= self.definitions == y.definitions
      retVal &= self.markers == y.markers
      
      # Decided not to check hint because Edict files don't have
      # hints.  Also, it's probably the right thing to do since
      # the hint doesn't affect if it's the same vocabulary
      
      # We won't test for score and position since they are artifacts
      # of the quiz (hint, hint)
    end
    return retVal
  end

  def ==(y)
    return eql?(y)
  end

  def definitions
    if @definitions
      return @definitions.join(", ")
    else
      return ""
    end
  end

  def definitions=(string)
    @definitions = string.split(", ")
  end

  def markers
    if @markers
      return @markers.join(", ")
    else
      return ""
    end
  end

  def markers=(string)
    @markers = string.split(", ")
  end

  def valid
    return (@definitions && (@definitions.length > 0) && @reading)
  end

  def parse(string)
    string.split("/").each { |part|
      case part
      when /^Kanji: (.*)/ then @kanji = $1
      when /^Hint: (.*)/ then @hint = $1
      when /^Reading: (.*)/ then @reading = $1
      when /^Definitions: (.*)/ then @definitions = $1.to_s.split(",")
      when /^Markers: (.*)/ then @markers = $1.to_s.split(",")
      when /^Score: (.*)/ then @score = $1.to_i
      when /^Bin: (.*)/ then @bin = $1.to_i
      when /^Level: (.*)/ then @level = $1.to_i
      when /^Position: (.*)/ then @position = $1.to_i
      else # Just chuck anything we don't understand
      end
    }
  end

  def to_csv
    retVal = ""
    if @kanji
      retVal += @kanji
    end
    retVal += ","
    if @hint
      retVal += @hint
    end
    retVal += ","
    retVal += @reading
    retVal += ","
    retVal += @definitions.join("/")
    retVal += ","
    retVal += @markers.join("/")
    return retVal
  end

  def to_tsv
    retVal = ""
    if @kanji
      retVal += @kanji
    end
    retVal += "\t"
    retVal += @reading
    retVal += "\t("
    retVal += markers
    retVal += ") "
    retVal += definitions
    return retVal
  end


  def parseCSV(string)
    fields = string.split(",")
    if fields.length == 5
      if fields[0] == ""
        @kanji = nil
      else
        @kanji = fields[0]
      end
      if fields[1] == ""
        @hint = nil
      else
        @kanji = fields[1]
      end
      @reading = fields[2]
      @definitions = fields[3].split("/")
      @markers = fields[4].split("/")
    end
  end

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

    retVal += "/Score: #{@score}"
    retVal += "/Bin: #{@bin}"
    retVal += "/Level: #{@level}"
    retVal += "/Position: #{@position}/\n"

    return retVal
  end

end
