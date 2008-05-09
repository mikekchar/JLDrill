require 'Context/View'

module JLDrill
	class OptionsView < Context::View
		def initialize(context)
			super(context)
			@optionsSet = false
			@options = Options.new(nil)
		end
		
		def optionsSet?
		    return @optionsSet
		end
		
		def update(options)
		    @options.assign(options)
		end
	end
end
