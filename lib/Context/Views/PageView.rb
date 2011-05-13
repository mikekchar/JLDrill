require 'Context/View'

module Context
	class PageView < View
		def initialize(context)
			super(context)
		end
		
		# The page view is meant to be the main view for a context
		# (in Gtk it's a window).  So if the view closes, it should
		# close the context.  Actually, I'm not sure if I like this
		# idea.  It might change.
		def close
			@context.close
		end
	end
end
