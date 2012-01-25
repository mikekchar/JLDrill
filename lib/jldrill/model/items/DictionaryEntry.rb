# encoding: utf-8

module JLDrill

    # A word in the dictionary.
    # It has a reference to a DictionaryLocation and may
    # have a cached Meaning
	class DictionaryEntry
        Headings = [["bothKanji", "Kanji", 90],
                    ["reading", "Reading", 130],
                    ["toVocab.definitions", "Meaning", 230]]

        attr_reader :kanji, :simplified, :reading, :dictionary, :position, 
            :relevance
        attr_writer :kanji, :simplified, :reading, :dictionary, :position,
            :relevance

        def initialize
            @kanji = ""
            @simplified = ""
            @reading = ""
            @dictionary = nil
            @position = -1
            @vocab = nil
            @relevance = 0 
        end

        # The DictionaryEntry is valid if there is a reading.  There doesn't need to
        # be a kanji
        def valid?
            return !@reading.empty?
        end

        def bothKanji
            retVal = @kanji
            if !@simplified.empty?
                retVal += "/#{@simplified}"
            end
            return retVal
        end

        def toVocab
            if @vocab.nil?
                @vocab = @dictionary.getVocab(@position)
            end
            return @vocab
        end

        def toMeaning
            @meaning = @dictionary.getMeaning(@position)
            return @meaning
        end

        def to_s
            return @dictionary.lines[@position]
        end

        def readingEql?(key)
            return @reading.eql?(key)
        end

        def kanjiEql?(key)
            retVal = false
            if !@kanji.empty?
                retVal |= @kanji.eql?(key)
            end
            if !@simplified.empty?
                retVal |= @simplified.eql?(key)
            end
            return retVal
        end

        def keyStartsWithReading?(key)
            return key.start_with?(@reading)
        end

        def keyStartsWithKanji?(key)
            retVal = false
            if !@kanji.empty?
                retVal |= key.start_with?(@kanji)
            end
            if !@simplified.empty?
                retVal |= key.start_with?(@simplified)
            end
            return retVal
        end

        def readingStartsWith?(key)
            return @reading.start_with?(key)
        end

        def kanjiStartsWith?(key)
            retVal = false
            if !@kanji.empty?
                retVal |= @kanji.start_with?(key)
            end
            if !@simplified.empty?
                retVal |= @simplified.start_with?(key)
            end
            return retVal
        end

        def startsWith?(key)
            return readingStartsWith(key) || kanjiStartsWith(key)
        end
    end
end

