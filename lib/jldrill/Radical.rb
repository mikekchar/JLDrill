module JLDrill

	class RadKEntry
	
		attr_reader :radical, :strokes, :altGlyph, :contents

		def initialize(radical, strokes, altGlyph)
			@radical = radical
			@strokes = strokes
			@altGlyph = altGlyph
			@contents = []
		end
		
		def RadKEntry.parse(string)
			entry = nil
			re = Regexp.new('^\$\ (\S)\ (\d+)\ ?(\S+)?', nil, 'U')
			if string =~ re
				radical = $1
				strokes = $2.to_i
				altGlyph = if $3.nil? then nil else $3.to_i(16) end
				entry = RadKEntry.new(radical, strokes, altGlyph)
			end
			entry
		end
		
		def parseContents(string)
			string.chomp
			re = Regexp.new('\s*',nil,'U')
			string.split(re)
		end
		
		def add(array)
			@contents += array
			@contents.uniq!
		end

	end
	
	class RadKComment
		attr_reader :contents
		
		def initialize(contents)
			@contents = contents
		end	
		
		def RadKComment.parse(string)
			comment = nil
			re = Regexp.new('^#(.*)\n?', nil, 'U')
			if string =~ re
				contents = $1
				comment = RadKComment.new(contents)
			end
			comment
		end
	end

	class RadKFile < Array
	
		def RadKFile.fromString(string)
			file = RadKFile.new
			current = nil
			string.each_line do |line|
				current = file.parse(current, line)
			end
			file
		end
		
		def RadKFile.open(filename)
			file = RadKFile.new
			current = nil
			IO.foreach(filename) do |line|
				current = file.parse(current, line)			
			end
			file
		end

		def parse(current, string)
			if(RadKComment.parse(string).nil?)
				entry = RadKEntry.parse(string)
				if(!entry.nil?)
					current = entry
					self.push(entry)
				else
					current.add(current.parseContents(string)) unless current.nil?
				end
			end
			current
		end
		
		def radicals(character)
			retVal = []
			self.each do |entry|
				if entry.contents.include?(character)
					retVal.push(entry.radical)
				end
			end
			retVal
		end
	end
end
