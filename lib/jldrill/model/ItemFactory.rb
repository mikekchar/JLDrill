require 'jldrill/model/ItemType'
require 'jldrill/model/Vocabulary'

module JLDrill
    class ItemFactory
        
        def ItemFactory::find(type)
            retVal = nil
            if type == "Vocabulary"
                retVal = ItemType.new("Vocabulary", Vocabulary)
                retVal.headings = [["kanji", "Kanji", 90],
                    ["reading", "Reading", 130],
                    ["definitions", "Meaning", 230]]
            end
            return retVal
        end
    end
end
