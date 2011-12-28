# encoding: utf-8

require 'jldrill/model/items/Dictionary'
require "jldrill/model/items/Vocabulary"
require 'jldrill/model/items/JWord'
require 'Context/Log'

module JLDrill

    # A JEDictionary is a Japanese to English Dictionary.
    # It is composed of an array of entries from an EDict
    # dictionary. These entries are parsed to create JWords.
    # The JWords can then further parse the entries to
    # create Meanings.
	class CEDictionary < Dictionary
        attr_reader :jWords

        LINE_RE_TEXT = '^([^\[\s]*)\s+([^\[\s]*)\[(.*)\]\s+\/(([^\/]*\/)+)\s*$'
        LINE_RE = Regexp.new(LINE_RE_TEXT, nil)
        GET_JWORD_RE = Regexp.new('^([^\[\s]*)\s+([^\[\s]*)\[(.*)\]\s+', nil)
        FIRST_CHAR_RE = Regexp.new("^(.)", nil)

        def hashSize
            return "雨".size
        end

        def getMeaning(position)
            retVal = ""
            if lines[position] =~ LINE_RE
                retVal = $4
            end
            return retVal
        end

        # Parse the line at the given position and return the a Vocabulary
        # containing the information (this is deprecated).
        def getVocab(position)
            retVal = nil
            if lines[position] =~ LINE_RE
                kanji = $1
                reading = $3
                english = JLDrill::Meaning.create($4)
                
                retVal = Vocabulary.new(kanji, reading, english.allDefinitions,
                                   english.allTypes, "", position)
            else
                Context::Log::warning("JLDrill::CEDictionary", 
                                      "Could not parse #{position}")
            end             
            return retVal                        
        end

        def getJWord(index)
            retVal = nil
            if lines[index] =~ GET_JWORD_RE
                retVal = JWord.new
                retVal.kanji = $1
                retVal.reading = $3
                retVal = hackWord(retVal)
            end
            return retVal
        end
    end
end

