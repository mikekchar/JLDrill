require 'Context/View'

module JLDrill
	class MainWindowView < Context::View
		def initialize(context)
			super(context)
		end
		
		def close
			@context.close
		end
		
		def loadReference
		    @context.loadReference
		end
		
		def edict
		    @context.reference
		end
	end
end
