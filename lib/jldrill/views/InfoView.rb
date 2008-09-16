require 'Context/View'

module JLDrill
	class InfoView < Context::View
	
		def initialize(context)
			super(context)
		end
		
		def destroy
		    # Only in the concrete class
		end
		
		def run(info)
		    @info = info
		end
		
	end
end