require 'Context/View'

module JLDrill

    class CommandView < Context::View
    
        attr_reader :save, :saveAs, :export, :open, :appendFile, 
                    :loadReference, :quit, :info, :statistics, :check,
                    :incorrect, :correct, :vocabTable, :options,
                    :resetQuiz, :editVocab, :addNewVocabulary, :ack, :about,
                    :drill, :deleteVocab
    
		def initialize(context)
			super(context)
			@save = Proc.new {@context.save}
			@saveAs = Proc.new {@context.saveAs}
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
			@editVocab = Proc.new {@context.editVocab}
			@addNewVocabulary = Proc.new {@context.addNewVocabulary}
			@ack = Proc.new {@context.ack}
			@about = Proc.new {@context.about}
            @drill = Proc.new {@context.drill}
            @deleteVocab = Proc.new {@context.deleteVocab}
		end	
		
		def setReviewMode(bool)
		    @context.setReviewMode(bool)
		end
		
		def getReviewMode
		    @context.getReviewMode
		end
	
    end
end
