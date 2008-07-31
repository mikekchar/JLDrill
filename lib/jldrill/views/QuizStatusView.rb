require 'Context/View'
require 'jldrill/model/Quiz/Quiz'

module JLDrill
	class QuizStatusView < Context::View
	
		def initialize(context)
			super(context)
		end

		def run
		    super
		end	
		
		def update(quiz)
		    # Should be overridden in the concrete class
		end	
	end
end
