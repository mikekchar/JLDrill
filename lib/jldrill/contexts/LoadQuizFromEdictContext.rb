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
            return "Merging #{@edict.shortFilename} data"
        end

        def readFile
            @quiz.reset
            size = @edict.length
            pos = 0
            @mainView.idle_add do
                limit = pos + @quiz.stepSize
                if limit > size then limit = size end
                while (pos < limit)
                    @quiz.contents.add(@edict.vocab(pos), 0)
                    pos += 1
                    @mainView.update(pos.to_f / size.to_f)
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

        def exit
            @quiz.name = @edict.shortFilename
            super
        end
    end
end
