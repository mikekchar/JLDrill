require 'Context/View'

module JLDrill
	class StatisticsView < Context::View
	    attr_reader  :quiz
	
		def initialize(context)
			super(context)
			@quiz = nil
		end
		
		def close
		    @context.exit
		end
		
		def update(quiz)
		    @quiz = quiz
		end
	end
end
