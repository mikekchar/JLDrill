module JLDrill

	class Radical

        RADICAL_RE = Regexp.new('(\S)\t(\S*)\t(\S*)\t([^\t]*)\t(\S+)?', nil, 'U')
        TO_A_RE = Regexp.new('\s*',nil,'U')
	
		attr_reader :radical, :reading, :altGlyphs, :meaning, :contents
		attr_writer :radical, :reading, :altGlyphs, :meaning, :contents

		def initialize(radical, reading, altGlyphs, meaning, contents)
			@radical = radical
			@reading = reading
			@altGlyphs = altGlyphs
			@meaning = meaning
			@contents = contents
		end
		
		def Radical.splitChars(string)
			if !string.nil?
			    string.split(TO_A_RE)
			else
			    []
			end
	    end
		
		def Radical.parse(string)
			entry = nil

			if string =~ RADICAL_RE
				radical = $1
				altGlyphs = Radical.splitChars($2)
				reading = $3
				meaning = $4
				contents = Radical.splitChars($5)
				entry = Radical.new(radical, reading, altGlyphs,
				                    meaning, contents)
			end
			entry
		end
		
		def eql?(radical)
		    self.to_s == radical.to_s
		end
		
		def to_s
		    retVal = @radical
		    if @altGlyphs.size > 0
		        retVal += "(" + @altGlyphs.join(",") + ")"
		    end
		    retVal += "   " + @reading + " - " + @meaning
            retVal		    
		end

	end

	class RadicalList < Array
	
		def RadicalList.fromString(string)
			file = RadicalList.new
			string.each_line do |line|
				file.parse(line)
			end
			file
		end
		
		def RadicalList.fromFile(filename)
			file = RadicalList.new
			IO.foreach(filename) do |line|
				file.parse(line)			
			end
			file
		end

		def parse(string)
			entry = Radical.parse(string)
			if(!entry.nil?)
				self.push(entry)
			end
		end
		
		def includesChar?(radicalChar)
		    item = self.find do |rad|
		        rad.radical == radicalChar
		    end
		    return !item.nil?
		end
		
		def radicals(character)
			retVal = RadicalList.new
			self.each do |entry|
				if entry.radical == character || 
				  entry.contents.include?(character)
					retVal.push(entry)
				end
			end
			retVal
		end
		
		def to_s
		    self.join("\n") + "\n"
		end
	end
end
