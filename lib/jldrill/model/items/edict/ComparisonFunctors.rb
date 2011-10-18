# encoding: utf-8
module JLDrill

    class StartsWith
        TO_A_RE = Regexp.new("",nil,"u")

        def initialize(string)
            @startsWithArray = string.split(TO_A_RE)
            if @startsWithArray.nil?
                @startsWithArray = []
            end
        end

        # Returns the number of characters at the beginning of
        # string that are also at the beginning of @startsWithArray
        def numCommonChars(string)
            i = 0
            if !string.nil?
                a = string.split(TO_A_RE)
                while (i < a.size) && (i < @startsWithArray.size) &&
                        (a[i] == @startsWithArray[i]) do
                    i += 1
                end
            end
            return i
        end

        def match(string)
            return numCommonChars(string) == @startsWithArray.size
        end
    end

    class Equals
        def initialize(string)
            @equalsString = string
        end

        def match(string)
            return @equalsString.eql?(string)
        end
    end
end
