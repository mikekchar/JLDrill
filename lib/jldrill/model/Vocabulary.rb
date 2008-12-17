require "jldrill/model/Quiz/ItemStatus"
require "jldrill/model/StringField"
require "jldrill/model/ListField"

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
        attr_writer :status
        
        def initialize(kanji=nil, reading=nil, definitions=nil, 
                       markers=nil, hint=nil, position=nil)
            @kanji = StringField.new("Kanji", kanji)
            @reading = StringField.new("Reading", reading)
            @hint = StringField.new("Hint", hint)
            @definitions = ListField.new("Definitions", definitions)
            @markers = ListField.new("Markers", markers)
            @status = JLDrill::ItemStatus.new
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
                @kanji.eql?(y.kanjiRaw) && 
                    @definitions.eql?(y.definitionsArray) &&
                    @markers.eql?(y.markersArray) && 
                    @reading.eql?(y.readingRaw)
            else
                false
            end
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
            @kanji.copy(vocab.kanjiField)
            @reading.copy(vocab.readingField)
            @definitions.copy(vocab.definitionsField)
            @markers.copy(vocab.markersField)
            @hint.copy(vocab.hintField)
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

        def kanjiField
            @kanji
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

        def readingField
            @reading
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

        def hintField
            @hint
        end
        
        def hintRaw
            @hint.raw
        end

        # Returns a string containing the definitions separated
        # by commas
        def definitions
            @definitions.output
        end

        def definitionsField
            @definitions
        end

        def definitionsRaw
            @definitions.raw
        end

        def definitionsArray
            @definitions.contents
        end

        # Assigns the definitions from a string of comma separated
        # definitions
        def definitions=(string)
            @definitions.assign(string)
        end
        
        # Returns true if there are definitions set on the Vocabulary
        def hasDefinitions?
            @definitions.assigned?
        end

        # Returns a string containing the markers separated
        # by commas
        def markers
            @markers.output
        end

        def markersField
            @markers
        end

        def markersArray
            @markers.contents
        end

        def markersRaw
            @markers.raw
        end

        # Assigns the definitions from a string of comma separated
        # definitions
        def markers=(string)
            @markers.assign(string)
        end
        
        # Returns true if there are definitions set on the Vocabulary
        def hasMarkers?
            @markers.assigned?
        end

        # Returns true if the vocabulary contains a reading and either 
        # at least one definition exists or kanji exists.
        def valid?
            @reading.assigned? &&
                (@definitions.assigned? || @kanji.assigned?)
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
                    @definitions.assign($1)
                when MARKERS_RE
                    @markers.assign($1)
                else # Maybe it's the status, if not ignore it
                    @status.parse(part)
                end
            end
        end

        # Output the contents in save file format *without the status*
        def contentString
            return @kanji.to_s + @hint.to_s + @reading.to_s +
                @definitions.to_s + @markers.to_s
        end
        
        # Output the vocabulary as a string in save file format
        def to_s
            retVal = contentString
            
            retVal += @status.to_s
            
            retVal += "/\n"
            
            return retVal
        end
        
    end
end
