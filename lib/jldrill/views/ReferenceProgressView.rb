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
            while !(block.call) do
                # Nothing
            end
		end
		
		def exit
		    @context.exit
		end
		
	end
end
