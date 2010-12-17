# -*- coding: utf-8 -*-

require 'jldrill/model/items/ItemFactory'

module JLDrill

    # A JWord is a Japanese Word in a Japanese to English dictionary.
    # It has a reference to a DictionaryLocation and may
    # have a cached Meaning
	class JWord
        attr_reader :kanji, :reading, :dictionary, :position, :itemType,
            :relevance
        attr_writer :kanji, :reading, :dictionary, :position,
            :relevance

        def initialize
            @kanji = ""
            @reading = ""
            @dictionary = nil
            @position = -1
            @itemType = ItemFactory::find(self.class)
            @vocab = nil
            @relevance = 0 
        end

        # The JWord is valid if there is a reading.  There doesn't need to
        # be a kanji
        def valid?
            return !@reading.empty?
        end

        def toVocab
            if @vocab.nil?
                @vocab = @dictionary.getVocab(@position)
            end
            return @vocab
        end

        def to_s
            return @dictionary.lines[@position]
        end

        def startsWith?(key)
            return @reading.start_with?(key) || @kanji.start_with?(key)
        end
    end
end

