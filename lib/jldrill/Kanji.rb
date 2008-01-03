module JLDrill

	class KanjidicEntry
	
		attr_reader :character, :jisCode, :meanings, :bushu
	
		def initialize(character, jisCode)
			@character = character
			@jisCode = jisCode
			@meanings = []
			@bushu = nil
		end
		
		def addMeanings(meanings)
			@meanings += meanings
		end
		
		def parseBushu(string)
			if string =~ Regexp.new('^B(\d+)')
				@bushu = $1.to_i(10) if @bushu.nil?
			end
		end
		
		def KanjidicEntry.parse(string)
			entry = nil
			if string =~ Regexp.new('^(\S)\ (\d+)\ (.*)', nil, 'U')
				character = $1
				jisCode = $2.to_i(16)
				meat = $3
				meat.slice!(/\ \{.*$/)
				codes = meat.split(' ')
				entry = KanjidicEntry.new(character, jisCode)
				meanings = string.split(Regexp.new('\}?\ \{', nil, 'U'))
				meanings.delete_at(0) unless meanings.empty?
				meanings[meanings.size - 1].slice!(/\}\s*/) unless meanings.empty?
				entry.addMeanings(meanings)
				codes.each do |code|
					entry.parseBushu(code)
				end
			end
			entry
		end
	end
end
