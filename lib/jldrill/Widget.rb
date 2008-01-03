module JLDrill

	# Abstract class that encapsulates a "widget" in the target
	# UI library.  It delegates the few functions that are
	# necessary to call from the abstract layer (such as adding
	# one widget to the other).  This avoids having to duplicate
	# code in every concrete UI library layer.
	class Widget
	
		attr_reader :delegate
	
		def initialize(delegate)
			@delegate = delegate
		end
		
		# Use this widget as a container for the passed widget
		def add(widget)
			# This is an abstract method, the child classes should
			# implement this
		end
	end
end
