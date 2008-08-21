require 'Context/View'

module JLDrill
	class PromptView < Context::View
	    attr_reader  :response, :title, :message
	
		def initialize(context, title, message)
			super(context)
			@title = title
			@message = message
			@response = @context.cancel
		end
		
		def destroy
		    # Only in the concrete class
		end
		
		def run
		    # Override in the concrete class
		end
		
	end
end
