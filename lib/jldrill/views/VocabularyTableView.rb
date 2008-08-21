require 'Context/View'

module JLDrill
	class VocabularyTableView < Context::View
	    attr_reader :quiz
	
		def initialize(context)
			super(context)
			@quiz = nil
		end
		
		def destroy
		    # Only in the concrete class
		end
		
		def run(quiz)
		    @quiz = quiz
		end
		
	end
end
