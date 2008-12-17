require 'jldrill/model/Quiz/ItemStatus'

module JLDrill

    # Holds an item for the quiz.  For memory and performance purposes 
    # these items are stored as:
    #
    #    o The class of the underlying object
    #    o A string containing the object
    #    o The ItemStatus of the object
    #
    # The string representation of the object can be obtain through to_s().
    # The object representation of the object can be obtained through to_o().
    #
    # Items stored here must implement the following:
    #    o to_s() -- returns a string representation of the object
    #    o create() -- accepts a string and creates the object
    class Item
        attr_reader :status

        def initialize(item)
            @itemClass = item.class
            @contents = item.contentString
            @status = item.status
        end

        def setStatus(status)
            @status.parse(status.to_s)
        end

        def to_s
            return @contents + @status.to_s + "/\n"
        end

        def to_o
            item = @itemClass.create(self.to_s)
            return item
        end

        def eql?(item)
            self.to_o.eql?(item.to_o)
        end

        def contain?(object)
            self.to_o.eql?(object)
        end
    end
end
