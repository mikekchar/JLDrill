require 'Context/View'

module JLDrill
	class MainWindowView < Context::View
		def initialize(context)
			super(context)
		end

        def open
            # Nothing to be done in the abstract class
        end
		
		def close
			@context.quit
		end
		
		def destroy
		    # Nothing to be done in the abstract class
		end
		
	end
end
