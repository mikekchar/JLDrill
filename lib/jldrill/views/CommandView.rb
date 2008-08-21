require 'Context/View'

module JLDrill

    class CommandView < Context::View
    
        attr_reader :save, :saveAs, :export, :open, :appendFile, 
                    :loadReference, :quit, :info, :statistics, :check,
                    :incorrect, :correct, :vocabTable, :options,
                    :resetQuiz, :displayVocab, :xReference, 
                    :addNewVocabulary, :ack, :about
    
		def initialize(context)
			super(context)
			@save = Proc.new {@context.save}
			@saveAs = Proc.new {@context.saveAs}
			@export = Proc.new {@context.export}
			@open = Proc.new {@context.open}
			@appendFile = Proc.new {@context.appendFile}
			@loadReference = Proc.new {@context.loadReference}
			@quit = Proc.new {@context.quit}
			@info = Proc.new {@context.info}
			@statistics = Proc.new {@context.statistics}
			@check = Proc.new {@context.check}
			@incorrect = Proc.new {@context.incorrect}
			@correct = Proc.new {@context.correct}
			@vocabTable = Proc.new {@context.vocabTable}
			@options = Proc.new {@context.options}
			@resetQuiz = Proc.new {@context.resetQuiz}
			@displayVocab = Proc.new {@context.displayVocab}
			@xReference = Proc.new {@context.xReference}
			@addNewVocabulary = Proc.new {@context.addNewVocabulary}
			@ack = Proc.new {@context.ack}
			@about = Proc.new {@context.about}
		end	
		
		def setReviewMode(bool)
		    @context.setReviewMode(bool)
		end
		
		def getReviewMode
		    @context.getReviewMode
		end
	
    end
end
