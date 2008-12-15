require 'jldrill/model/Edict/Edict'
require 'jldrill/model/Vocabulary'

# Just like an Edict, only hashed on the first character of the
# reading so that we can search it faster.  Note, it's dead slow
# to iterate through the list, so don't do it if at all possible
module JLDrill
    class HashedEdict < Edict

        KEY_RE = /^(.)/mu

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

        def include?(vocab)
            found = false
            if @hash
                key = findKey(vocab.reading)
                bin = @hash[key]
                if bin
                    i = 0
                    while !found && (i < bin.size)
                        found = (vocab == vocab(i))
                    end
                end
            end
            return found
        end

        def search(reading)
            result = []
            if @hash
                key = findKey(reading)
                bin = @hash[key]
                re = Regexp.new("^#{reading}")
                if bin
                    bin.each do |position|
                        vocab = vocab(position)
                        if !vocab.nil? && !vocab.reading.nil?
                            if re.match(vocab.reading)
                                result.push(vocab)
                            end
                        end
                    end
                end
            end
            
            return result
        end

    end
end
