require 'Context/View'
require 'jldrill/model/Problem'
require 'jldrill/views/ItemHintView'
require 'Context/Version'

module JLDrill
    # The ProblemView is made up of three sub-Views: The ItemHintView,
    # the QuestionView and the AnswerView.  The ProblemView works as
    # a mediator to tie the three views together and present a
    # unified interface to the Context.
	class ProblemView < Context::View

        attr_reader :itemHints
	
		def initialize(context)
			super(context)
            @itemHints = context.viewBridge.ItemHintView.new(context)
		end

        def viewAddedTo(parent)
            self.addView(@itemHints)
        end

        def removingViewFrom(parent)
            self.removeView(@itemHints)
        end

		def newProblem(problem, differs)
            itemHints.newProblem(problem, differs)
		end	

        def updateProblem(problem, differs)
            itemHints.updateProblem(problem, differs)
        end
		
		def showAnswer
		    # Should be overridden in the concrete class
		end
		
		def kanjiInfo(character)
		    @context.kanjiInfo(character)
		end
		
		def kanjiLoaded?
		    @context.kanjiLoaded?
		end
		
	end
end
