require 'jldrill/model/Item'
require 'jldrill/model/items/edict/Edict'
require 'jldrill/model/items/edict/ComparisonFunctors'
require 'jldrill/model/items/Vocabulary'

# Just like an Edict, only hashed on the first character of the
# reading so that we can search it faster.  Note, it's dead slow
# to iterate through the list, so don't do it if at all possible
module JLDrill
    class HashedEdict < Edict

        # Create hash keys from the first 3 characters in the reading.
        # This will create small enough bins that we can parse them quickly
        KEY_RE = /^(..?.?)/mu
        KEY_LIMIT_RE = /...+/mu
        KANJIKEY_RE = /^(.)/mu

        def initialize(file=nil)
            super(file)
            @hash = {}
            @kanjiHash = {}
        end

        def reset
            super
            @hash = {}
            @kanjiHash = {}
        end

        def findKey(string)
            retVal = "None"
            if string
                if string =~ KEY_RE then retVal = $1 end
            end
            return retVal
        end

        def findKanjiKey(kanji)
            retVal = "None"
            if kanji
                if kanji =~ KANJIKEY_RE then retVal = $1 end
            end
            return retVal
        end

        def add(tags, position)
            super(tags, position)
            if !tags[1].nil?
                key = findKey(tags[1])
                (@hash[key] ||= []).push(position)
            end
            if !tags[0].nil?
                key = findKanjiKey(tags[0])
                (@kanjiHash[key] ||= []).push(position)
            end
        end

        # Returns the bin that contains the reading, or nil if it is not found
        def findBin(reading)
            bin = nil
            if !@hash.nil?
                key = findKey(reading)
                bin = @hash[key]
            end
            return bin
        end

        # Return an array of bins with keys matching re
        # This will probably be slow
        def findBinsWith(re)
            result = []
            keys = @hash.keys.delete_if do |key|
                !re.match(key)
            end
            keys.each do |key|
                result.push(@hash[key])
            end
            return result
        end

        # Returns the bin that contains the kanji, or nil if it is not found
        def findKanjiBin(kanji)
            bin = nil
            if !@kanjiHash.nil?
                key = findKanjiKey(kanji)
                bin = @kanjiHash[key]
            end
            return bin
        end

        # searches the bin using the regular expression, re, for the reading
        def searchBin(reading, bin, re)
            result = []
            if !bin.nil?
                bin.each do |position|
                    vocab = vocab(position)
                    if !vocab.nil? && !vocab.reading.nil?
                        if re.match(vocab.reading)
                            result.push(Item.create(vocab.to_s))
                        end
                    end
                end
            end
            return result
        end

        # searches the bin using the regular expression, re, for the kanji
        def searchKanjiBin(kanji, bin, re)
            result = []
            if !bin.nil?
                bin.each do |position|
                    vocab = vocab(position)
                    if !vocab.nil? && !vocab.kanji.nil?
                        if re.match(vocab.kanji)
                            result.push(Item.create(vocab.to_s))
                        end
                    end
                end
            end
            return result
        end

        def search(reading)
            result = []
            re = JLDrill::StartsWith.new(reading)

            # Because they are kanji characters and strings are bytes,
            # we have to check the size using a regular expression
            if reading =~ KEY_LIMIT_RE
                # If it's bigger than the limit size
                bin = findBin(reading)
                result = searchBin(reading, bin, re)
            else
                # If it's smaller than the limit size, then
                # other bins might also match.
                bins = findBinsWith(re)
                bins.each do |bin|
                    result += searchBin(reading, bin, re)
                end
            end
            return result
        end

        def include?(vocab)
            reading = vocab.reading
            bin = findBin(reading)
            re = JLDrill::Equals.new(reading)
            return searchBin(reading, bin, re).any? do |item|
                item.to_o.eql?(vocab)
            end
        end
        
        def searchKanji(kanji)
            result = []
            re = JLDrill::StartsWith.new(kanji)

            bin = findKanjiBin(kanji)
            result = searchKanjiBin(kanji, bin, re)
            return result
        end

        def includeKanji?(vocab)
            kanji = vocab.kanji
            bin = findKanjiBin(kanji)
            re = JLDrill::Equals.new(kanji)
            return searchKanjiBin(kanji, bin, re).any? do |item|
                item.to_o.eql?(vocab)
            end
        end

        def findReadingStartingWith(string)
            keys = @hash.keys.delete_if do |key|
                !string.start_with?(key)
            end
            retVal = []
            keys.each do |key|
                retVal += @hash[key] 
            end
            return retVal
        end

        # return all the vocab that starts with the same characters as
        # the string 
        def findStartingWith(string)
            bin = findKanjiBin(string)
            if bin.nil?
                bin = []
            end
            readingBin = findReadingStartingWith(string)
            if !readingBin[0].nil?
                bin += readingBin
            end
            return bin.collect do |pos|
                v = vocab(pos)
                if string.start_with?(v.kanji) ||
                    string.start_with?(v.reading)
                    v
                else
                    nil
                end
            end.delete_if do |v|
                v.nil?
            end.sort do |x, y|
                if x.kanji.nil?
                    left = x.reading
                else
                    left = x.kanji
                end
                if y.kanji.nil?
                    right = y.reading
                else
                    right = y.kanji
                end
                right.size <=> left.size
            end
        end

    end
end
