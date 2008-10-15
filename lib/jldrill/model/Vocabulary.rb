require "jldrill/model/VocabularyStatus"
require "jldrill/model/Field"

# Class file for Japanese vocabulary
# Currently geared towards edict, but that might change

module JLDrill
    class Vocabulary

        KANJI_RE = /^Kanji: (.*)/
        HINT_RE = /^Hint: (.*)/
        READING_RE = /^Reading: (.*)/
        DEFINITIONS_RE = /^Definitions: (.*)/
        MARKERS_RE = /^Markers: (.*)/
        QUOTE_RE = /["]/
        RETURN_RE = /[\n]/
        JP_COMMA_RE = Regexp.new("[、]", nil, "U")

        attr_reader :status

        def initialize(kanji=nil, reading=nil, definitions=nil, 
                       markers=nil, hint=nil, position=nil)
            @kanji = Field.new("Kanji", kanji)
            @reading = Field.new("Reading", reading)
            @hint = Field.new("Hint", hint)
            @definitions = definitions
            @markers = markers
            @status = JLDrill::VocabularyStatus.new(self)
            if !position.nil? then @status.position = position end
        end
        
        # Create a new vocaublary item by parsing the string passed in.
        def Vocabulary.create(string)
            retVal = Vocabulary.new
            retVal.parse(string)
            retVal
        end

        # Returns a deep copy of this item.  Note: Does *not* copy parameters
        # that are not saveable.  This is because of my cheezy implementation.
        def clone
            Vocabulary.create(self.to_s)
        end

        # True if the two vocabulary are discussing the same word
        # This does *not* compare the hint, status
        # since they do not affect the meaning of the word.
        def eql?(y)
            if !y.nil?
                (@kanji.eql?(y.kanjiRaw)) && sameDefinitions(y) &&
                    (@markers.eql?(y.markersArray)) && 
                    (@reading.eql?(y.readingRaw))
            else
                false
            end
        end

        # I think there may be a bug in ruby 1.8.6 in Array.eql?
        def sameDefinitions(y)
            if @definitions.nil?
                if y.definitionsArray.nil?
                    return true
                else
                    return false
                end
            else
                if y.definitionsArray.nil?
                    return false
                end
            end
            retVal = (@definitions.size == y.definitionsArray.size)
            if retVal
                0.upto(@definitions.size - 1) do |i|
                    retVal &= (@definitions[i] == y.definitionsArray[i])
                end
            end
            retVal
        end

        # I think there may be a bug in ruby 1.8.6 in Array.eql?
        def sameMarkers(y)
            if @markers.nil?
                if y.markersArray.nil?
                    return true
                else
                    return false
                end
            else
                if y.markersArray.nil?
                    return false
                end
            end
            retVal = (@markers.size == y.markersArray.size)
            if retVal
                0.upto(@markers.size - 1) do |i|
                    retVal &= (@markers[i] == y.markersArray[i])
                end
            end
            retVal
        end


        # True if the two vocabulary are discussing the same word
        # This does *not* compare the hint or status
        # since they do not affect the meaning of the word.
        def ==(y)
            return eql?(y)
        end

        # Assign the contents of vocab to this object.
        # NOTE: It does *not* assign status
        def assign(vocab)
            @kanji.assign(vocab.kanjiRaw)
            @reading.assign(vocab.readingRaw)
            self.definitions= vocab.definitions
            self.markers= vocab.markers
            @hint.assign(vocab.hintRaw)
        end
        
        # Unquote some things
        def processOutput(text)
            if text.nil?
                return nil
            end
            text = text.gsub(JP_COMMA_RE, ",")
            eval("\"#{text.gsub(QUOTE_RE, "\\\"")}\"")
        end

        def processInput(text)
            if text.nil?
                return nil
            end
            text = text.gsub(RETURN_RE, "\\n")
            text
        end

        def notEmpty(string)
            if (!string.nil? && !string.empty?)
                string
            else
                nil
            end
        end
        
        def hasKanji?
            @kanji.assigned?
        end
        
        def kanji=(string)
            @kanji.assign(string)
        end

        def kanji
            @kanji.output
        end
        
        def kanjiRaw
            @kanji.raw
        end
        
        def hasReading?
            @reading.assigned?
        end

        def reading=(string)
            @reading.assign(string)
        end
        
        def reading
            @reading.output
        end

        def readingRaw
            @reading.raw
        end

        def hasHint?
            @hint.assigned?
        end

        def hint=(string)
            @hint.assign(string)
        end

        def hint
            @hint.output
        end
        
        def hintRaw
            @hint.raw
        end

        # splits the string on commas and destroys and leading space
        def Vocabulary.splitCommas(string)
            array = string.split(",")
            array.each do |item|
                item.strip!
            end
            array
        end
        
        # Join the array into a string with ", " in between each item.
        # if the array is empty or nil, print ""
        def Vocabulary.joinCommas(array)
            if !array.nil?
                return array.join(", ")
            else
                return ""
            end
        end
        
        # Returns a string containing the definitions separated
        # by commas
        def definitions
            processOutput(Vocabulary.joinCommas(@definitions))    
        end

        def definitionsRaw
            Vocabulary.joinCommas(@definitions)
        end

        def definitionsArray
            @definitions
        end

        # Assigns the definitions from a string of comma separated
        # definitions
        def definitions=(string)
            string = processInput(string)
            if (!string.nil? && !string.empty?)
                @definitions = Vocabulary.splitCommas(string)
            else
                @definitions = nil
            end
        end
        
        # Returns true if there are definitions set on the Vocabulary
        def hasDefinitions?
            !@definitions.nil?
        end

        # Returns a string containing the markers separated
        # by commas
        def markers
            Vocabulary.joinCommas(@markers)
        end

        def markersArray
            @markers
        end

        def markersRaw
            Vocabulary.joinCommas(@definitions)
        end

        # Assigns the definitions from a string of comma separated
        # definitions
        def markers=(string)
            string = processInput(string)
            if (!string.nil? && !string.empty?)
                @markers = Vocabulary.splitCommas(string)
            else
                @markers = nil
            end
        end
        
        # Returns true if there are definitions set on the Vocabulary
        def hasMarkers?
            !@markers.nil?
        end

        # Returns true if the vocabulary contains a reading and either 
        # at least one definition exists or kanji exists.
        def valid?
            retVal = false
            if @reading.assigned? 
                if (!@definitions.nil? && (@definitions.length > 0) || 
                    @kanji.assigned?)
                    retVal = true
                end
            end
            retVal
        end

        # Parses a vocabulary value in save format.
        def parse(string)
            string.split("/").each do |part|
                case part
                when KANJI_RE
                    @kanji.assign($1)
                when HINT_RE 
                    @hint.assign($1)
                when READING_RE 
                    @reading.assign($1)
                when DEFINITIONS_RE 
                    self.definitions = $1
                when MARKERS_RE
                    self.markers = $1
                else # Maybe it's the status, if not ignore it
                    @status.parse(part)
                end
            end
        end
        
        # Output the vocabulary as a string in save file format
        def to_s
            retVal = @kanji.to_s + @hint.to_s + @reading.to_s

            if (!@definitions.nil?) && (!@definitions.empty?)
                retVal += "/Definitions: #{@definitions.join(",")}"
            end

            if @markers && (not @markers.empty?)
                retVal += "/Markers: #{@markers.join(",")}"
            end
            
            retVal += @status.to_s
            
            retVal += "/\n"

            return retVal
        end

    end
end
