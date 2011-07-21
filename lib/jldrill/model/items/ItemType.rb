# encoding: utf-8
module JLDrill
    class ItemType
        attr_reader :headings
        attr_writer :headings
        
        def initialize(name, itemClass)
            @name = name
            @class = itemClass
            @headings = {}
        end

        def create(string)
            @class.create(string)
        end
    end
end
