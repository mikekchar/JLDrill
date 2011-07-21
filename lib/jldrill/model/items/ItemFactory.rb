# encoding: utf-8
require 'jldrill/model/items/ItemType'
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/items/JWord'

module JLDrill
    class ItemFactory
        
        def ItemFactory::find(type)
            retVal = nil
            if type.eql? Vocabulary
                retVal = ItemType.new(type.to_s, type)
                retVal.headings = [["kanji", "Kanji", 90],
                                   ["reading", "Reading", 130],
                                   ["definitions", "Meaning", 230]]
            elsif type.eql? JWord
                retVal = ItemType.new(type.to_s, type)
                retVal.headings = [["kanji", "Kanji", 90],
                                   ["reading", "Reading", 130],
                                   ["toVocab.definitions", "Meaning", 230]]
            end
            return retVal
        end
    end
end
