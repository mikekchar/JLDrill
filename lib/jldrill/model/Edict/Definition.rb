require "jldrill/model/Edict/GrammarType"

module JLDrill

    # Holds a definition for an Edict entry.  Each definition
    # may have one or more type indicating its type of speach
    # (verb, noun, etc)
    class Definition

        DEFINITION_RE = /^(\(\S*\))\s?(.*)/
        SEPARATOR_RE = /\)|,/
        COMMA_RE = /[,]/

        attr_reader :types, :value
        attr_writer :types, :value
        	
        def initialize()
            @value = ""
            @types = []
        end
        
        def Definition.create(string)
            definition = Definition.new
            definition.parse(string)
            definition
        end

        def parse(string)
            @types = []
            while string =~ DEFINITION_RE
        	    types = GrammarType.create($1)
        	    if(types.empty?)
        	        # There were no types in the parenthesis, so it must
        	        # be part of the definition.
        	        @value += $1 + " "
        	    else
        	        @types += types
        	    end
                string = $2
            end
            @value += string.gsub(COMMA_RE, "\\,")
        end
        
        def eql?(definition)
            @value.eql?(definition.value) && (@types.size == definition.types.size) &&
                @types.all? do |x|
                    definition.types.find do |y|
                        x.eql?(y)
                    end
                end
        end        

        def to_s
          	retVal = ""
          	if @types.size > 0
          	    retVal += "(" + @types.join(",") + ")"
          	end
          	retVal += @value
          	retVal
        end
    end
end

