require "jldrill/model/Edict/Definition"

module JLDrill
    
    # Holds a collection of definitions that defines a typical usage
    # for the word.  It also holds an index number for the usage.
    class Usage

    	attr_reader :index
    	attr_writer :index

    	def initialize
    		@definitions = []
    		@index = 0
    	end
    	
    	def Usage.create(string, index=0)
    	    usage = Usage.new
    	    usage.index = index
    	    usage.parse(string)
    	    usage
    	end
    	
    	def parse(string)
    		string.split("/").each do |definition|
    			defn = Definition.create(definition)
    			@definitions.push(defn)
    		end
    	end
    	
    	# Returns all the types in the definitions
    	def types
    		retVal = []
    		@definitions.each do |defn|
    			retVal += defn.types
    		end
    		retVal
    	end

         # Returns all the values for the definitions
    	def definitions
    		retVal = []
    		@definitions.each do |defn|
    			retVal.push defn.value unless defn.value == ""
    		end
    		retVal
    	end
    	
    	def to_s
    	    retVal = ""
    	    if index != 0
    	        retVal += "(" + index.to_s + ")"
    	    end
    	    retVal += @definitions.join("/")
    	end
    end
end
