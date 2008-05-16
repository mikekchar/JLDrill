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
		
		def setOptions
		    @context.setOptions
		end
		
		def quiz
		    @context.quiz
		end

		def quiz=(aQuiz)
		    @context.quiz = aQuiz
		end
	end
end
