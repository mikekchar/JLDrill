# Represents a Field in a Vocabulary

module JLDrill
    class Field

        QUOTE_RE = /["]/
        RETURN_RE = /[\n]/
        JP_COMMA_RE = Regexp.new("[、]", nil, "U")

        def initialize(name, string=nil)
            @name = name
            @contents = string
        end

        def processInput(text)
            if text.nil?
                return nil
            end
            text = text.gsub(RETURN_RE, "\\n")
            text
        end

        def processOutput(text)
            if text.nil?
                return nil
            end
            text = text.gsub(JP_COMMA_RE, ",")
            eval("\"#{text.gsub(QUOTE_RE, "\\\"")}\"")
        end

        def raw
            @contents
        end

        def copy(field)
            @contents = field.raw
        end

        def assign(string)
            @contents = processInput(string)
        end

        def assigned?
            !@contents.nil? && (@contents != "")
        end

        def output
            if assigned?
                processOutput(@contents)
            else
                nil
            end
        end

        def eql?(string)
            if string.nil? || string.empty?
                !assigned?
            else
                @contents.eql?(string)
            end
        end

        def to_s
            if assigned?
                "/#{@name}: #{@contents}"
            else
                ""
            end
        end
    end
end
