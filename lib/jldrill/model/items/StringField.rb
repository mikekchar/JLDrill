# encoding: utf-8
require "jldrill/model/items/Field"

# Represents a string type Field in a Vocabulary

module JLDrill
    class StringField < Field

        def initialize(name, data)
            super(name)
            @contents = data
        end
        
        def fromString(string)
            string
        end
            
        # Returns the actual contents of the field
        def contents
            @contents
        end

        # Returns a string of the field that has not been processed
        # for output
        def raw
            if assigned?
                @contents
            else
                ""
            end
        end

        def copy(field)
            if field.assigned?
                @contents = field.contents
            else
                @contents = nil
            end
        end

        def assign(string)
            @contents = processInput(string)
        end

        def eql?(string)
            if contents.nil? || contents.empty?
                !assigned?
            else
                @contents.eql?(string)
            end
        end

    end
end

