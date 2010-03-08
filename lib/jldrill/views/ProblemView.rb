require 'Context/View'
require 'jldrill/model/Problem'
require 'jldrill/views/ItemHintView'
require 'Context/Version'

module JLDrill
    # The problem view displays the current problem questions
    # and answer.  It also houses a subview which gives hints
    # on the current item (differs from dictionary, intransitive, etc).
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

		def newProblem(problem)
            itemHints.newProblem(problem)
		end	

        def updateProblem(problem)
            itemHints.updateProblem(problem)
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

        def expandWithSavePath(filename)
            @context.expandWithSavePath(filename)
        end
		
	end
end
