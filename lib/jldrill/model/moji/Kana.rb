module JLDrill
    # Represents a japanese phonetic character (either hiragana or
    # katakana).
	class Kana
	
	    STROKES_RE = /^S(\d+)/
	
		attr_reader :character, :romaji, :pronunciation, 
                    :strokes, :examples
	
		def initialize(character, romaji, pronunciation, strokes, examples)
			@character = character
			@romaji = romaji
			@pronunciation = pronunciation
			@strokes = strokes
			@examples = examples
		end

        def Kana.getParts(string, separator)
            retVal = nil
            if !string.nil?
                retVal = string.split(separator, -1)
            end
            retVal
        end
        
        def Kana.validSections?(sections)
            !sections.nil? && sections.size == 6 && !sections[0].nil?
        end
		
		def Kana.parse(string)
			entry = nil
			sections = Kana.getParts(string.chomp, "|")
			return if !Kana.validSections?(sections)
			character = sections[0]
			romaji = Kana.getParts(sections[2], "/")
			examples = Kana.getParts(sections[5], ",")
            pronunciation = sections[3]
			commands = Kana.getParts(sections[1], " ")
			strokes = nil
			commands.each do |command|
			    case command
			        when STROKES_RE
        				strokes = $1.to_i(10)
			    end
			end
			Kana.new(character, romaji, pronunciation, strokes, examples)
		end

        def eql?(kana)
            @character.eql?(kana.character) &&
                @romaji.eql?(kana.romaji) &&
                @pronunciation.eql?(kana.pronunciation) &&
                @strokes.eql?(kana.strokes) &&
                @examples.eql?(kana.examples)
        end
		
		def to_s
		    retVal = @character
		    retVal += " [" + @romaji.join(" ") + "]\n"
            retVal += @pronunciation + "\n\n"
		    retVal += "Strokes: #{@strokes}\n\n"
            retVal += "English Examples: " + @examples.join(", ") + "\n"
		    retVal
		end
	end

	class KanaList < Array
	
		def KanaList.fromString(string)
			list = KanaList.new
			string.each_line do |line|
				list.parse(line)
			end
			list
		end
		
		def KanaList.fromFile(filename)
			list = KanaList.new
			IO.foreach(filename) do |line|
				list.parse(line)			
			end
			list
		end
		
		def parse(string)
			entry = Kana.parse(string)
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
end
