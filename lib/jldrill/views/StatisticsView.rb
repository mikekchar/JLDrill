require 'Context/View'

module JLDrill
	class StatisticsView < Context::View
	
		def initialize(context)
			super(context)
		end
		
		def close
		    @context.exit
		end
	end
end
