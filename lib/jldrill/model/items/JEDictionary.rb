# encoding: utf-8

require 'jldrill/model/items/Dictionary'
require "jldrill/model/items/Vocabulary"
require 'jldrill/model/items/DictionaryEntry'
require 'Context/Log'

module JLDrill

    # A JEDictionary is a Japanese to English Dictionary.
    # It is composed of an array of entries from an EDict
    # dictionary. These entries are parsed to create DictionaryEntry.
    # The DictionaryEntry can then further parse the entries to
    # create Meanings.
	class JEDictionary < Dictionary

        LINE_RE_TEXT = '^([^\[\s]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$'
        LINE_RE = Regexp.new(LINE_RE_TEXT, nil)
        GET_DE_RE = Regexp.new('^([^\[\s]*)\s+(\[(.*)\]\s+)?', nil)
        KANA_RE = /（(.*)）/
        FIRST_CHAR_RE = Regexp.new("^(.)", nil)

        # Ruby 1.8 counts in bytes so Japanese characters are 3 characters
        # long.  Ruby 1.9 counts in characters, so Japanese characters are
        # 1 character each.  When we are hashing we need to use a Japanese
        # character for a key.  When creating the slices to search for the
        # hash key we need to know how many characters to strip off. This
        # function tells you what that is.
        def hashSize
            return "あ".size
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
                
                # Hack for JLPT files
                if reading =~ KANA_RE
                    reading = nil
                    hint = $1
                end

                if(reading == "" || reading == nil)
                    reading = kanji
                    kanji = nil
                end

                retVal = Vocabulary.new(kanji, reading, english.allDefinitions,
                                   english.allTypes, hint, position)
            else
                Context::Log::warning("JLDrill::JEDictionary", 
                                      "Could not parse #{position}")
            end             
            return retVal                        
        end

        # Compensate for files that have missing kanji or
        # JLPT files which have a strange format.
        def hackWord(word)
            # Hack for JLPT files
            if word.reading =~ KANA_RE || word.reading.nil? ||
                    word.reading.empty?
                word.reading = word.kanji
                word.kanji = ""
            end
            if word.kanji.nil?
                word.kanji = ""
            end
            return word
        end

        def getDictionaryEntry(index)
            retVal = nil
            if lines[index] =~ GET_DE_RE
                retVal = DictionaryEntry.new
                retVal.kanji = $1
                retVal.reading = $3
                retVal.dictionary = self
                retVal.position = index
                retVal = hackWord(retVal)
            end
            return retVal
        end
    end
end
