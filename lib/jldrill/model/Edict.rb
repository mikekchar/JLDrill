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

# Contains code necessary to read in an EDict file
# Also will parse hacked up JLPT Edict files

require "jldrill/model/Vocabulary"

# 2 helper classes for parsing the english meanings in
# dictionary.
class EdictDefinition

  DEFINITION_RE = /^(\(\S*\))\s?(.*)/
  SEPARATOR_RE = /\)|,/

  attr_reader :types, :value
	
  def initialize(string)
    @value = ""
    @types = []
    parse(string)
  end

  def parse(definition)
    types = []
    while definition =~ DEFINITION_RE
      definition = $2
        
      typestring = $1
	  types += typestring.delete("(").split(SEPARATOR_RE)
    end
    @value = definition
    @types = types
  end
  
  def to_s
  	retVal = ""
  	if @types.size > 0
  		retVal += "(" + @types.join(", ") + ") "
  	end
  	retVal += @value
  	retVal
  end
end

class EdictSense

	attr_reader :index

	def initialize(string, index)
		@definitions = []
		@index = index
		parse(string)
	end
	
	def parse(string)
		string.split("/").each do |definition|
			defn = EdictDefinition.new(definition)
			@definitions.push(defn)
		end
	end
	
	def types
		retVal = []
		@definitions.each do |defn|
			retVal += defn.types
		end
		retVal
	end

	def definitions
		retVal = []
		@definitions.each do |defn|
			retVal.push defn.value unless defn.value == ""
		end
		retVal
	end
	
	def to_s
		"[" + index.to_s + "] " + @definitions.join("/")
	end
end

class EdictMeaning

  SENSE_RE = /\(\d+\)\s?/

  attr_reader :senses

  def initialize(string)
    @types = []
    @senses = getSenses(string)
  end

  def getSenses(string)
    retVal = []
    senses = string.split(SENSE_RE)
    i = 1
    senses.each do |sense|
      es = EdictSense.new(sense, i)
      if(es.definitions.empty?)
        # Hack to get the tags at the beginning of the meaning
      	@types += es.types
      else
      	retVal.push(es)
      	i += 1
      end
    end
    retVal
  end

  def types
    retVal = []
    retVal += @types
    @senses.each do |sense|
    	retVal += sense.types
    end
    retVal
  end

  def definitions
    retVal = []
    printSenses = @senses.size > 1
  	@senses.each do |sense|
  		defs = sense.definitions
  		if printSenses && !defs[0].nil?
  			defs[0] = "[" + sense.index.to_s + "] " + defs[0]
  		end
  		retVal += defs
  	end
  	retVal
  end

  def to_s
  	retVal = ""
  	if types.size > 0
  		retVal += "(" + types.join(",") + ") "
  	end
  	retVal += @senses.join("/") + "\n"
    retVal
  end
end

class Edict

  LINE_RE = /^([^\[]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$/
  KANA_RE = /（(.*)）/
  COMMENT_RE = /^\#/

  attr_reader :file

  def initialize(file)
    @file = file
    @vocab = []
  end

  def eachVocab
    @vocab.each {|vocab|
      yield(vocab)
    }
  end

  def vocab(index)
    return @vocab[index]
  end

  def length
    return @vocab.length
  end

  def add(vocab)
    if vocab
      @vocab.push(vocab)
    end
  end

  def parse(line, position)
    retVal = false
    if line =~ LINE_RE
      kanji = $1
      kana = $3
      english = EdictMeaning.new($4)

      # Hack for JLPT files
      if kana =~ KANA_RE
        kana = nil
        hint = $1
      end

      if(kana == "" || kana == nil)
        kana = kanji
        kanji = nil
      end

      add(Vocabulary.new(kanji, kana, english.definitions,
                  english.types, hint, position))
      retVal = true
    end             
    return retVal                        
  end

  def read(&progress)
    i = 0
    size = File.size(@file).to_f
    total = 0.to_f
    report = 0
    IO.foreach(@file) { |line|
      # Only report every 1000 lines because it's expensive  
      total += line.length.to_f
      if progress && (report == 1000)
        report = 0
        progress.call(total / size)
      end
      report += 1
      unless line =~ COMMENT_RE
        if parse(line, i)
          i += 1
        end
      end
    }
  end

  def shortFile
    pos = @file.rindex('/')
    if(pos)
      return @file[(pos+1)..(@file.length-1)]
    else
      return @file
    end
  end

  def include?(vocab)
  	if(!@vocab.nil?)
  		return @vocab.include?(vocab)
  	else
  		return false
  	end
  end

  def search(reading)
    result = []
    if @vocab
      @vocab.each { |vocab|
        if vocab.reading
          re = Regexp.new("^#{reading}")
          if re.match(vocab.reading)
            result.push(vocab)
          end
        end
      }
    end
    return result
  end

  def to_s()
    retVal = ""
    @vocab.each { |word|
       retVal += word.to_s + "\n"
    }
    return retVal
  end
end

