# encoding: utf-8
require 'jldrill/model/items/JWord'
require 'jldrill/views/gtk/widgets/WordTable'

module JLDrill::Gtk
    class SearchTable < WordTable

        attr_reader :kanji, :reading

        def initialize(container, kanji, reading)
            @container = container
            @reading = reading
            @kanji = kanji
            candidates = @container.search(kanji, reading)
            super(candidates, JLDrill::JWord) do |item|
                @container.searchActivated(item)
            end
        end

        def searchEqual(model, column, key, iter)
            retVal = true
            vocab = iter[0]
            if !vocab.nil?
                retVal = !vocab.startsWith?(key)
            end
            return retVal
        end

        def getContents(item)
            return item
        end

        def getContentsAsVocab(item)
            return item.toVocab
        end

        def selectClosestMatch(vocab)
            super(vocab)
            if hasSelection?
                focusTable
            end
        end

    end
end
