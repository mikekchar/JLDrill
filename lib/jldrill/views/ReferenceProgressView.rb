require 'Context/View'

module JLDrill
	class ReferenceProgressView < Context::View
		def initialize(context)
			super(context)
		end
		
		def destroy
		    # Only in concrete class
		end
		
		def update(fraction)
		    # This will be overridden by the concrete classes
		end
		
		def idle_add(&block)
		    # This will be overridden by the concrete classes
            # However, in order to load the dictionary in the
            # tests it's implemented here.
            # WARNING: Do not call this from the concrete class!
            while !(block.call) do
                # Nothing
            end
            self.exit
		end
		
		def exit
		    @context.exit
		end
		
	end
end
