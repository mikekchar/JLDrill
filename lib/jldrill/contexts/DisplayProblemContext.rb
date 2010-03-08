require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/ProblemView'

module JLDrill

	class DisplayProblemContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.ProblemView.new(self)
        end

        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
            if !@parent.nil?
                if !@parent.quiz.nil?
                    @parent.quiz.publisher.subscribe(self, "load")
                    @parent.quiz.publisher.subscribe(self, "newProblem")
                    @parent.quiz.publisher.subscribe(self, "problemModified")
                end
                if !@parent.reference.nil?
                    @parent.reference.publisher.subscribe(self, "edictLoad")
                end
                newProblemUpdated(@parent.quiz.currentProblem)
            end
		end
		
		def exit
            if !@parent.nil?
                if !@parent.quiz.nil?
                    @parent.quiz.publisher.unsubscribe(self, "load")
                    @parent.quiz.publisher.unsubscribe(self, "newProblem")
                    @parent.quiz.publisher.unsubscribe(self, "problemModified")
                end
                if !@parent.reference.nil?
                    @parent.reference.publisher.subscribe(self, "edictLoad")
                end
            end
		    super
		end

        def differs?(problem)
            exists = true
            if @parent.reference.loaded? && !problem.nil?
                exists = @parent.reference.include?(problem.item.to_o)
		    end
		    return !exists
        end

        def loadUpdated(quiz)
            # There isn't likely a new problem at this point, but this
            # will clear the panes and update the status for the new
            # quiz
            newProblemUpdated(quiz.currentProblem)
        end

		def newProblemUpdated(problem)
            @mainView.newProblem(problem)
		end

		def problemModifiedUpdated(problem)
            @mainView.updateProblem(problem)
		end

		def edictLoadUpdated(reference)
            quiz = @parent.quiz
            @mainView.updateProblem(quiz.currentProblem)
		end

        def showAnswer
            @mainView.showAnswer
        end
        
        def kanjiLoaded?
            !@parent.kanji.nil?
        end
        
        def kanjiInfo(character)
            retVal = ""
            kanji = @parent.kanji.findChar(character)
            if !kanji.nil?
                retVal = kanji.withRadical_to_s(@parent.radicals)
            else
                kana = @parent.kana.findChar(character)
                if !kana.nil?
                    retVal = kana.to_s
                end
            end
            retVal
        end

        def expandWithSavePath(filename)
            if !@parent.quiz.nil?
                return @parent.quiz.useSavePath(filename)
            else
                return filename
            end
        end
    end
end
