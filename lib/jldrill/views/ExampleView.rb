require 'Context/View'

module JLDrill
	class ExampleView < Context::View
	
		def initialize(context)
			super(context)
		end
		
		def close
		    @context.exit
		end

		def destroy
            # Only for the concrete class
        end

		def update(examples)
		    # Only for the concrete class
		end
	end
end
