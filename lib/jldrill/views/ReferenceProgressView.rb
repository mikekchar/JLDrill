require 'Context/View'

module JLDrill
	class ReferenceProgressView < Context::View
		def initialize(context)
			super(context)
		end
		
		def update(fraction)
		    # This will be overridden by the concrete classes
		end
	end
end
