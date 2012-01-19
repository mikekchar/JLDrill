# encoding: utf-8

module JLDrill

    # Describes how a piece of vocabulary has been used in a sentence.
    # It includes the kanji, reading, the sense that the vocabulary
    # was used, the grammatical form that was used and whether
    # the usage has been checked as being accurate.
    # This class also includes input and output routines for
    # the Tanaka "B" lines.
    class VocabularyUsage
        attr_reader :kanji, :reading, :sense, :usedForm, :checked
        attr_writer :kanji, :reading, :sense, :usedForm, :checked
 
        B_LINE_RE = /^([^(\[{~]*)(\(([^)]*)\))?(\[([^\]]*)\])?(\{([^}]*)\})?(~)?/u
        HASH_RE = /([^{(\[~]*(\([^)]*\))?)/u

        # Map of VocabularyUsages to file positions that can be searched by
        # kanji and reading quickly.  This is used to store the location
        # in the example dictionary where each vocabulary is used.
        class Map
            # Result of searching a UsageMap
            # The successfulHash is the actual hash value that returned results
            # The positions is an array of positions in a file
            class SearchResult
                attr_reader :successfulHash, :positions

                def initialize(successfulHash, positions)
                    @successfulHash = successfulHash
                    @positions = positions
                end
            end

            def initialize
                @usages = {}
            end

            # Add a Vocabulary usage corresponding to Tanaka "B" line data
            # and map it to the position, pos.
            def add(usageData, pos)
                hash = VocabularyUsage.hashFrom_B_line(usageData)
                if !hash.empty?
                    (@usages[hash] ||= []).push(pos)
                end
            end

            # Take an entire Tanaka "B" line for an example sentences
            # and add it to the map with position, pos.
            def add_B_line(b_line, pos)
                w = b_line.split(' ')
                w.each do |usageData|
                    add(usageData, pos)
                end
            end

            # Search for VocabularyUsages which have the giving kanji and reading.
            # If kanji is nil, reading will be used for the kanji (useful for
            # vocabulary without kanji).  This will first search for entries
            # with both kanji and reading specified (to disambiguate entries
            # with the same kanji and different readings).  If this is empty,
            # it will search for entries with just the kanji specified.
            def search(kanji, reading)
                hash = VocabularyUsage.hashFromStrings(kanji, reading)
                positions = @usages[hash]
                if positions.nil?
                    # The corpus only uses readings to disambiguate
                    # kanji.  Most usages don't have readings.  So
                    # if we don't find anything, search again without
                    # the reading.
                    hash = JLDrill::VocabularyUsage.hashFromStrings(kanji, nil)
                    positions = @usages[kanji]
                end

                return SearchResult.new(hash, positions)
            end
        end

        def initialize()
            @kanji = ""
            @reading = ""
            @sense = 0
            @usedForm = ""
            @checked = false
        end

        # Create a VocabularyUsage from data taken from a Tanaka "B" line
        # Note: This is not the whole line.  Just the data for a single
        # vocabulary.
        def VocabularyUsage::from_B_line(data)
            retVal = VocabularyUsage.new()
            if B_LINE_RE.match(data)
                retVal.kanji = $1
                retVal.reading = $3
                if !$5.nil?
                    retVal.sense = $5.to_i
                else
                    retVal.sense = 0
                end
                retVal.usedForm = $7
                retVal.checked = $8.eql?("~")
            end
            return retVal
        end

        # Create a hash that can be used in a hash table for searching
        # for vocabulary usages.  This has is generated from a Tanaka
        # "B" line.  It is composed of the kanji followed by the
        # reading, enclosed in parentheses, if the reading is ambiguous
        # from the kanji.
        def VocabularyUsage::hashFrom_B_line(data)
            retVal = ""
            if HASH_RE.match(data)
                retVal = $1
            end
            return retVal
        end

        # Create a hash that can be used in a hash table for searching
        # for vocabulary usages. This is generated from kanji and reading
        # strings.  Either can be nil.  If the kanji is nil, then the reading
        # is used for the kanji (for vocabulary without kanji).  The reading
        # should normally be nil, unless the reading from the kanji is
        # ambiguous.
        def VocabularyUsage::hashFromStrings(kanji, reading)
            if reading.nil?
                return kanji
            elsif kanji.nil?
                return reading
            else
                return "#{kanji}(#{reading})"
            end
        end

        # Output the Vocabulary usage in the same form as used
        # by the B lines in the Tanaka Corpus 
        def to_B_line
            retVal = @kanji.to_s
            if !@reading.nil?
                retVal += "(#{@reading})"
            end
            if @sense != 0
                retVal += "[#{@sense.to_s}]"
            end
            if !@actual.nil?
                retVal += "{#{@actual.to_s}}"
            end
            if @checked
                retVal += "~"
            end
            return retVal
        end

        # Output a string form of the VocabularyUsage.
        # Currently this is just the Tanaka "B" line data
        # for the Vocabulary Usage.
        def to_s
            return to_B_line
        end
    end

end
