require 'jldrill/model/Edict/Edict'
require 'jldrill/model/Vocabulary'

# Just like an Edict, only hashed on the first character of the
# reading so that we can search it faster.  Note, it's dead slow
# to iterate through the list, so don't do it if at all possible
module JLDrill
    class HashedEdict < Edict

        # Create hash keys from the first 3 characters in the reading.
        # This will create small enough bins that we can parse them quickly
        KEY_RE = /^(..?.?)/mu

        def initialize(file=nil)
            super(file)
            @hash = {}
        end

        def findKey(string)
            retVal = "None"
            if string
                if string =~ KEY_RE then retVal = $1 end
            end
            return retVal
        end

        def add(reading, position)
            super(reading, position)
            if !reading.nil?
                key = findKey(reading)
                if @hash.has_key?(key)
                    @hash[key].push(position)
                else
                    @hash[key] = [position]
                end
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

        # searches the bin using the regular expression, re, for the reading
        def searchBin(reading, bin, re)
            result = []
            if !bin.nil?
                print "HashedEdict::searchBin size=#{bin.size}\n"
                bin.each do |position|
                    vocab = vocab(position)
                    if !vocab.nil? && !vocab.reading.nil?
                        if re.match(vocab.reading)
                            result.push(vocab)
                        end
                    end
                end
                print "HashedEdict::searchBin Done\n"                
            end
            return result
        end

        def search(reading)
            bin = findBin(reading)
            re = Regexp.new("^#{reading}")
            return searchBin(reading, bin, re)
        end

        def include?(vocab)
            reading = vocab.reading
            bin = findBin(reading)
            re = Regexp.new("^#{reading}$")
            return searchBin(reading, bin, re).include?(vocab)
        end
    end
end
