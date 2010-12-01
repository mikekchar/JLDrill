require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/FileProgressContext'

module JLDrill

    # Loads a file displaying a progress bar as it is loading.
	class LoadQuizFromEdictContext < FileProgressContext
		
		def initialize(viewBridge)
			super(viewBridge)
            @quiz = nil
            @edict = nil
		end

        def getFilename
            return "data from #{@edict.shortFilename}"
        end

        def readFile
            @quiz.reset
            size = @edict.length
            pos = 0
            @mainView.idle_add do
                limit = pos + @quiz.stepSize
                if limit > size then limit = size end
                while (pos < limit)
                    vocab = @edict.vocab(pos)
                    if !vocab.nil?
                        @quiz.contents.add(@edict.vocab(pos), 0)
                    end
                    pos += 1
                    @mainView.update(pos.to_f / size.to_f)
                end
                if pos >= size
                    exitLoadQuizFromEdictContext
                end
                pos >= size
            end
        end

        def isValid?(parent)
            return !parent.nil? && !@quiz.nil? && !@edict.nil?
        end

        def enter(parent, quiz, edict)
            @quiz = quiz
            @edict = edict
            super(parent)
        end

        def exitLoadQuizFromEdictContext
            self.exit
        end

        def exit
            @quiz.name = @edict.shortFilename
            super
        end
    end
end
