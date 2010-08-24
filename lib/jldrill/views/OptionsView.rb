require 'Context/View'

module JLDrill
	class OptionsView < Context::View
	    attr_reader :options
	
		def initialize(context)
			super(context)
			@optionsSet = false
			@options = Options.new(nil)
		end

        def destroy
            # Only in concrete class
        end

		def optionsSet=(bool)
		    @optionsSet = bool
		end
		
		def optionsSet?
		    return @optionsSet
		end
		
		def update(options)
		    @options.assign(options)
		end

        def getDictionaryFilename
            @context.getDictionaryFilename
        end

        # Overridden in the concrete class.
        def setDictionaryFilename(filename)
            # Nothing to do.  This just updates the UI.
        end
		
		# Overridden in the concrete class.  But generally, this
		# will set the options and then exit.
		def run
		    exit
		end
		
		def exit
		    @context.exit
		end

	end
end
