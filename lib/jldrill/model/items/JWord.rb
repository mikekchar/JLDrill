# -*- coding: utf-8 -*-
module JLDrill

    # A JWord is a Japanese Word in a Japanese to English dictionary.
    # It has a reference to a DictionaryLocation and may
    # have a cached Meaning
	class JWord
        attr_reader :kanji, :reading, :dictionary, :position
        attr_writer :kanji, :reading, :dictionary, :position

        def initialize
            @kanji = ""
            @reading = ""
            @dictionary = nil
            @position = -1
        end

        # The JWord is valid if there is a reading.  There doesn't need to
        # be a kanji
        def valid?
            return !@reading.empty?
        end

        def toVocab
            return @dictionary.getVocab(@position)
        end

        def to_s
            return @dictionary.lines[@position]
        end
    end
end

