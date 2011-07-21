# encoding: utf-8
require "jldrill/model/items/edict/Usage"

module JLDrill

    class Meaning

        USAGE_DIVIDER_RE = /\s?\(\d+\)\s?/

        attr_reader :usages, :types, :definitions
        attr_writer :usages

        def initialize()
            @types = []
            @usages = []
        end
        
        def Meaning.create(string)
            meaning = Meaning.new
            meaning.parse(string)
            meaning
        end

        def parse(string)
            @usages = []
            parts = string.split(USAGE_DIVIDER_RE)
            i = 1
            parts.each do |usage|
                es = JLDrill::Usage.create(usage, i)
                if(es.allDefinitions.empty?)
                # Hack to get the tags at the beginning of the meaning
                	@types += es.allTypes
                else
                	@usages.push(es)
                	i += 1
                end
            end
        end

        def allTypes
            retVal = []
            retVal += @types
            @usages.each do |usage|
            	retVal += usage.allTypes
            end
            retVal
        end

        def allDefinitions
            retVal = []
            printUsages = @usages.size > 1
        	@usages.each do |usage|
        		defs = usage.allDefinitions
        		if printUsages && !defs[0].nil?
        			defs[0] = "(" + usage.index.to_s + ") " + defs[0]
        		end
        		retVal += defs
        	end
        	retVal
        end

        def to_s
        	retVal = ""
        	if types.size > 0
        		retVal += "(" + @types.join(",") + ") "
        	end
        	retVal += @usages.join(" ") + "\n"
        retVal
        end
    end

end
