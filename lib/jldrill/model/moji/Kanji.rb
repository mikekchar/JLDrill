# encoding: utf-8
require 'jldrill/model/util/DataFile'
require 'jldrill/model/moji/Radical'

module JLDrill

    # Represents a Kanji (chinese character)
	class Kanji
	
	    BUSHU_RE = /^B(\d+)/
	    GRADE_RE = /^G(\d+)/
	    STROKES_RE = /^S(\d+)/
        PINYIN_RE = /^Y([^|\s]+)/
	
		attr_reader :character, :readings, :meanings, :bushu, 
                    :grade, :strokes, :pinyin
	
		def initialize(character, readings, meanings, bushu, 
                       grade, strokes, pinyin)
			@character = character
			@readings = readings
			@meanings = meanings
			@bushu = bushu
			@grade = grade
			@strokes = strokes
            @pinyin = pinyin
		end

        def Kanji.getParts(string, separator)
            retVal = nil
            if !string.nil?
                retVal = string.split(separator, -1)
            end
            retVal
        end
        
        def Kanji.validSections?(sections)
            !sections.nil? && sections.size == 6 && !sections[0].nil?
        end
		
		def Kanji.parse(string)
			entry = nil
			sections = Kanji.getParts(string.chomp, "|")
			return if !Kanji.validSections?(sections)
			character = sections[0]
			readings = Kanji.getParts(sections[2], " ")
			meanings = Kanji.getParts(sections[5], ",")
			commands = Kanji.getParts(sections[1], " ")
			bushu = nil
			grade = nil
			strokes = nil
            pinyin=[]
			commands.each do |command|
			    case command
			        when BUSHU_RE
        				bushu = $1.to_i(10)
			        when GRADE_RE
        				grade = $1.to_i(10)
			        when STROKES_RE
        				strokes = $1.to_i(10)
                    when PINYIN_RE
                        pinyin.push($1)
			    end
			end
			Kanji.new(character, readings, meanings, bushu, grade, strokes, pinyin)
		end
		
		# Outputs values for optional items
		def optional_to_s(item)
		    if item.nil?
		        "*"
		    else
		        item.to_s
		    end
		end
		
		def optional_join(list, separator)
		    if list.nil?
		        ""
		    else
		        list.join(separator)
		    end
		end
		
		# This will create a string with the main bushu first, identified
		# with a *, followed by the rest of the radicals
		def radicals_to_s(radicals)
		    retVal = ""
    		rads = radicals.radicals(@character)
    		if !@bushu.nil?
		        bushu = radicals[@bushu - 1]
        		retVal += "* " + bushu.to_s + "\n  "
        		rads.delete(bushu)
            end
    		retVal += rads.join("\n  ")
		end
		
		def pinyin_radicals_to_s(kanjilist, radicals)
		    retVal = ""
    		rads = radicals.radicals(@character)
    		if !@bushu.nil?
		        bushu = radicals[@bushu - 1]
        		retVal += "* " + bushu.to_s_with_pinyin(kanjilist) + "\n  "
        		rads.delete(bushu)
            end
            rads.each do |rad|
                retVal += rad.to_s_with_pinyin(kanjilist) + "\n  "
            end
            retVal
		end

		# Outputs kanji data with the added radical information
		# radicals is a radical list
		def withRadical_to_s(radicals)
		    retVal = @character
		    retVal += " [" + optional_join(@readings, " ") + "]\n"
		    retVal += optional_join(@meanings, ", ") + "\n\n"
		    retVal += "Grade " + optional_to_s(@grade) + ", "
		    retVal += "Strokes " + optional_to_s(@strokes) + "\n"
    		retVal += "\nRadicals:\n"
    		retVal += radicals_to_s(radicals)
		end
		
        def withPinYinRadical_to_s(kanjilist, radicals)
		    retVal = @character
		    retVal += " [" + optional_join(@pinyin, " ") + "]\n"
		    retVal += optional_join(@meanings, ", ") + "\n\n"
		    retVal += "Grade " + optional_to_s(@grade) + ", "
		    retVal += "Strokes " + optional_to_s(@strokes) + "\n"
    		retVal += "\nRadicals:\n"
    		retVal += pinyin_radicals_to_s(kanjilist, radicals)
        end
		
		def to_s
		    retVal = @character
		    retVal += " [" + optional_join(@readings, " ") + "]\n"
		    retVal += optional_join(@meanings, ", ") + "\n\n"
		    retVal += "Grade " + optional_to_s(@grade) + ", "
		    retVal += "Strokes " + optional_to_s(@strokes) + "\n"
		    retVal += "Bushu " + optional_to_s(@bushu) + "\n"
		    retVal
		end
		
        def to_s_with_pinyin
		    retVal = @character
		    retVal += " [" + optional_join(@pinyin, " ") + "]\n"
		    retVal += optional_join(@meanings, ", ") + "\n\n"
		    retVal += "Grade " + optional_to_s(@grade) + ", "
		    retVal += "Strokes " + optional_to_s(@strokes) + "\n"
		    retVal += "Bushu " + optional_to_s(@bushu) + "\n"
		    retVal
		end
	end

    # An array of Kanji.  Useful for loading the kanji data.
	class KanjiList < Array
	
		def KanjiList.fromString(string)
			list = KanjiList.new
			string.each_line do |line|
				list.parse(line)
			end
			list
		end
		
		def KanjiList.fromFile(filename)
			list = KanjiList.new
			IO.foreach(filename) do |line|
				list.parse(line)			
			end
			list
		end
		
		def parse(string)
			entry = Kanji.parse(string)
			if(!entry.nil?)
				self.push(entry)
			end
		end
		
		def findChar(char)
		    self.find do |entry|
		        entry.character == char
		    end
		end

		def to_s
			self.join("\n")
		end
	end

    class KanjiFile < DataFile
        attr_reader :kanjiList
        attr_writer :kanjiList

        def initialize
            super
            @kanjiList = KanjiList.new
            @stepSize = 100
        end

        def dataSize
            @kanjiList.size
        end

        def parser
            @kanjiList
        end
    end

end
