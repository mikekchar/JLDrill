require "jldrill/model/Field"

# Represents a list type Field in a Vocabulary

module JLDrill
    class ListField < Field

        SEPARATOR_RE = /[^\\],/

        def initialize(name, data)
            super(name)
            @contents = data
        end

        def fromString(string)
            if string.nil? || string.empty?
                @contents = nil
            else
                @contents = string.split(",")
                merge = false
                delete = []
                0.upto(@contents.size - 1) do |i|
                    if merge
                        @contents[i - 1] += "," + @contents[i]
                        delete.push(i)
                    end
                    merge = @contents[i].end_with?("\\")
                    @contents[i].strip!
                end
                delete.reverse.each do |i|
                    @contents.delete_at(i)
                end
            end
        end

        def contents
            @contents
        end

        def raw
            if assigned?
                @contents.join(",")
            else
                ""
            end
        end

        # I stupidly didn't have spaces for my raw output previously
        # so this means that I've got to duplicate this method here.
        def output
            if assigned?
                processOutput(@contents.join(", "))
            else
                ""
            end
        end


        def copy(field)
            @contents = []
            if field.assigned?
                field.contents.each do |a|
                    @contents.push(a)
                end
            else
                @contents = nil
            end
        end

        def eql?(array)
            if !assigned?
                return array.nil? || array.empty?
            end
               
            if array.nil? || array.empty?
                return false
            end

            if @contents.size != array.size
                return false
            end

            return @contents.eql?(array)
        end
    end
end
