# encoding: utf-8
# Represents a Field in a Vocabulary
# This is an abstract class.  The concrete class must implement:
#
#     fromString() -- Returns contents from a string without input processing
#     contents() -- Returns the contents of the field unaltered
#     raw()      -- Returns a string of the contents unaltered
#     copy()     -- Copies the contents from a field if it is assigned
#     eql?()     -- Returns true if the contents are eql? to the passed contents


module JLDrill
    class Field

        QUOTE_RE = /["]/
        RETURN_RE = /[\n]/
        SLASH_RE = /[\/]/
        ESCAPED_COMMA_RE = Regexp.new("\\,", nil)
        ESCAPED_SLASH_RE = Regexp.new("\\/", nil)

        def initialize(name)
            @name = name
        end

        def processInput(text)
            if text.nil? || text.empty?
                return nil
            end
            text = text.gsub(RETURN_RE, "\\n")
            text
        end

        def processOutput(text)
            if text.nil?
                return nil
            end
            text = text.gsub(ESCAPED_COMMA_RE, ",")
            text = text.gsub(ESCAPED_SLASH_RE, "/")
            eval("\"#{text.gsub(QUOTE_RE, "\\\"")}\"")
        end

        def assign(string)
            string = processInput(string)
            fromString(string)
        end

        def assigned?
            !contents().nil? && !contents.empty?
        end

        def output
            if assigned?
                processOutput(raw())
            else
                nil
            end
        end

        def to_s
            if assigned?
                "/#{@name}: " + raw()
            else
                ""
            end
        end
    end
end
