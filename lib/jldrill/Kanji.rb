require 'jldrill/Radical'

module JLDrill

	class KanjidicEntry
	
		attr_reader :character, :jisCode, :meanings, :bushu, :grade
	
		def initialize(character, jisCode, radkfile)
			@character = character
			@jisCode = jisCode
			@meanings = []
			@bushu = nil
			@grade = nil
			@radicals = nil
			@bushuChar = nil
			@radkfile = radkfile
		end
		
		def addMeanings(meanings)
			@meanings += meanings
		end
		
		def parseBushu(string)
			if string =~ Regexp.new('^B(\d+)')
				@bushu = $1.to_i(10) if @bushu.nil?
			end
		end
		
		def parseGrade(string)
			if string =~ Regexp.new('^G(\d+)')
				@grade = $1.to_i(10) if @grade.nil?
			end
		end

		def KanjidicEntry.parse(string, radkfile)
			entry = nil
			if string =~ Regexp.new('^(\S)\ ([0-9a-fA-F]+)\ (.*)', nil, 'U')
				character = $1
				jisCode = $2.to_i(16)
				meat = $3
				meat.slice!(/\ \{.*$/)
				codes = meat.split(' ')
				entry = KanjidicEntry.new(character, jisCode, radkfile)
				meanings = string.split(Regexp.new('\}?\ \{', nil, 'U'))
				meanings.delete_at(0) unless meanings.empty?
				meanings[meanings.size - 1].slice!(/\}\s*/) unless meanings.empty?
				entry.addMeanings(meanings)
				codes.each do |code|
					entry.parseBushu(code)
					entry.parseGrade(code)
				end
			end
			entry
		end

		def radicals
			@radicals = @radkfile.radicals(@character) if @radicals.nil?
			@radicals
		end
		
		def bushuChar
			return "*"
		end
		
		def to_s
			if @grade.nil?
				grade = "*"
			else
				grade = @grade.to_s
			end
			@character + " Gr: " + grade + " " + self.bushuChar + " (" + self.radicals.join(", ") + "): " + @meanings.join(", ")
		end
	end

	class KanjidicComment
		attr_reader :contents
		
		def initialize(contents)
			@contents = contents
		end	
		
		def KanjidicComment.parse(string)
			comment = nil
			re = Regexp.new('^#(.*)\n?', nil, 'U')
			if string =~ re
				contents = $1
				comment = KanjidicComment.new(contents)
			end
			comment
		end
	end


	
	class KanjidicFile < Array
	
		attr_reader :radkfile
	
		def initialize(radkfile, array=nil)
			super(array) if !array.nil?
			@radkfile = radkfile
		end
		
		def KanjidicFile.fromString(string, radkfile)
			file = KanjidicFile.new(radkfile)
			string.each_line do |line|
				file.parse(line)
			end
			file
		end
		
		def KanjidicFile.open(filename, radkfile)
			file = KanjidicFile.new(radkfile)
			IO.foreach(filename) do |line|
				file.parse(line)			
			end
			file
		end
		
		def parse(string)
			if(KanjidicComment.parse(string).nil?)
				entry = KanjidicEntry.parse(string, @radkfile)
				if(!entry.nil?)
					self.push(entry)
				end
			end
		end

		def select
			array = super
			KanjidicFile.new(@radkfile, array)
		end
		
		def to_s
			self.join("\n")
		end
	end
end
