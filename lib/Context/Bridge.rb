module Context

    # This class is used to specify the namespace for a symbol
    # according to a priority list.  When you create the Bridge
    # you initialize it either with a single module name, or an
    # array of module names.  Calling "bridge.symbol" will return
    # the class in desired namespace (or nil if it doesn't exist)
    # If the Bridge was initialized with an array, it will pick
    # the first namespace that evaluates the symbol into something
    # that actually exists.
	class Bridge

        # Takes either a module name, or an array of module names
		def initialize(mods)
		    if mods.class != Array
    			@mod = mods
    			@mods = nil
    	    else
    	        @mods = mods
    	        @mod = nil
    	    end
		end
		
		# Convert the module name and symbol to a string
		def symbolToS(mod, symbol)
		    mod.to_s + "::" + symbol.to_s
		end
		
		# Evaluate the module and symbol, returning the class.
		# If it doesn't exist, return nil
		def evalClass(mod, symbol)
            retVal = nil
            if !mod.nil?
                begin
                    retVal = mod.class_eval(symbol.to_s)
                rescue
                end
    		end
            return retVal
		end
		
		# Returns true if the mod and symbol evaluate to a class in the system.
		def classExists?(mod, symbol)
    	    symbolToS(mod, symbol).eql?(evalClass(mod, symbol).to_s)
        end
        
        # Return the class specified by the stored module and the symbol
        # If an array of modules was stored, walk through them and pick
        # the first one that creates an extant class.
		def method_missing(symbol)
		    if !@mod.nil?
    			@mod.class_eval(symbol.to_s)
    	    elsif !@mods.nil?
    	        mod = @mods.find do |mod|
    	            classExists?(mod, symbol)
    	        end
    	        evalClass(mod, symbol)
    	    else
    	        nil
    	    end
		end
		
	end
end
