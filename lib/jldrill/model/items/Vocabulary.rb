# encoding: utf-8
require "jldrill/model/items/StringField"
require "jldrill/model/items/ListField"

# Class file for Japanese vocabulary
# Currently geared towards edict, but that might change

module JLDrill
    class Vocabulary

        DELIMITER_RE =/[^\\]\//
        KANJI_RE = /^Kanji: (.*)/
        HINT_RE = /^Hint: (.*)/
        READING_RE = /^Reading: (.*)/
        DEFINITIONS_RE = /^Definitions: (.*)/
        MARKERS_RE = /^Markers: (.*)/
        QUOTE_RE = /["]/
        RETURN_RE = /[\n]/
        TO_A_RE = Regexp.new("",nil,'u')

        Headings = [["kanji", "Kanji", 90],
                    ["reading", "Reading", 130],
                    ["definitions", "Meaning", 230]]

        def initialize(kanji=nil, reading=nil, definitions=nil, 
                       markers=nil, hint=nil, position=nil)
            @kanji = StringField.new("Kanji", kanji)
            @reading = StringField.new("Reading", reading)
            @hint = StringField.new("Hint", hint)
            @definitions = ListField.new("Definitions", definitions)
            @markers = ListField.new("Markers", markers)
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
        # This does *not* compare the hint
        # since it does not affect the meaning of the word.
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
        # This does *not* compare the hint
        # since it does not affect the meaning of the word.
        def ==(y)
            return eql?(y)
        end

        # Returns a hash for the Vocabulary.
        # The hash is generated from the reading and kanji
        def hash
            hashstring = ""
            hashstring += readingRaw
            hashstring += kanjiRaw
            return hashstring.hash
        end

        # Returns the number of characters at the beginning of
        # string1 that are also at the beginning of string2.
        def numCommonChars(string1, string2)
            i = 0
            if !string1.nil? && !string2.nil?
                a1 = string1.split(TO_A_RE)
                a2 = string2.split(TO_A_RE)
                while (i < a1.size) && (i < a2.size) &&
                        (a1[i] == a2[i]) do
                    i += 1
                end
            end
            return i
        end

        # Returns a rank based on how "close" the vocab is
        # to this one.  Higher numbers are "closer".
        def rank(vocab)
            theRank = 0
            if !vocab.nil?
                theRank = numCommonChars(reading, vocab.reading) * 1000
                theRank += numCommonChars(kanji, vocab.kanji) * 100
                if !definitionsArray.nil?
                    definitionsArray.each do |meaning|
                        if vocab.definitions.include?(meaning)
                            theRank += meaning.split(TO_A_RE).size
                        end
                    end
                end
                if !markersArray.nil?
                    markersArray.each do |marker|
                        if vocab.markers.include?(marker)
                            theRank += marker.split(TO_A_RE).size
                        end
                    end
                end
            end
            return theRank
        end

        def arrayStartsWith?(array, string)
            retVal = false
            size = string.split(TO_A_RE).size
            if !array.nil?
                array.any? do |thing|
                    retVal = numCommonChars(thing, string) == size
                end
            end
            return retVal
        end

        # Returns true if any of the fields start with the string
        def startsWith?(string)
            size = string.split(TO_A_RE).size
            return (numCommonChars(reading, string) == size) ||
                (numCommonChars(kanji, string) == size) ||
                arrayStartsWith?(definitionsArray, string) ||
                arrayStartsWith?(markersArray, string)
        end

        # Assign the contents of vocab to this object.
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

        # Split string on / allowing it to be escaped with a \
        def split(string)
            retVal = []
            int = ""
            esc = false
            string.split(TO_A_RE).each do |letter|
                if letter == "/"
                    if !esc
                        retVal.push(int)
                        int = ""
                    else
                        int += letter
                        esc = false
                    end
                elsif letter == "\\"
                    int += letter
                    if !esc
                        esc = true
                    else
                        esc = false
                    end
                else
                    esc = false
                    int += letter
                end
            end
            if !int.empty?
                retVal.push(int)
            end
            return retVal
        end

        # Parses a vocabulary value in save format.
        def parse(string)
            split(string).each do |part|
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
                else 
                    # Something we don't understand.  Just ignore it
                end
            end
        end

        # Output the contents in save file format
        def contentString
            return @kanji.to_s + @hint.to_s + @reading.to_s +
                @definitions.to_s + @markers.to_s
        end
        
        # Output the vocabulary as a string in save file format
        def to_s
            contentString
        end

        def to_edict
            return self.kanji.to_s + " [" + self.reading.to_s + "] " + 
                "(" + self.markers.to_s + ") " + self.definitions.to_s
        end
        
    end
end
