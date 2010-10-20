require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadFileContext'
require 'jldrill/contexts/GetFilenameContext'

module JLDrill

	class LoadQuizContext < Context::Context

        attr_reader :getFilenameContext
		
		def initialize(viewBridge)
			super(viewBridge)
            @loadFileContext = LoadFileContext.new(@viewBridge)
            @getFilenameContext = GetFilenameContext.new(@viewBridge)
            # Set the initial directory to the quiz Data dir
			@getFilenameContext.directory = File.join(JLDrill::Config::DATA_DIR,
                                                      "quiz")
		end

        def createViews
            @mainView =  @viewBridge.VBoxView.new(self)
        end

        def destroyViews
            @mainView = nil
        end

        def exitLoadQuizContext
            self.exit
        end

        def loadAsEdict(quiz, filename)
            edict = Edict.new
            @loadFileContext.onExit do
                quiz.loadFromDict(edict)
                exitLoadQuizContext
            end
            @loadFileContext.enter(self, edict, filename)
        end

        def loadAsQuiz(quiz, filename)
            @loadFileContext.onExit do
                exitLoadQuizContext
            end
            @loadFileContext.enter(self, quiz, filename)
        end

        def enter(parent, quiz)
            super(parent)
            filename = @getFilenameContext.enter(self, 
                                                  GetFilenameContext::OPEN)
            if !filename.nil? &&  !JLDrill::Quiz.drillFile?(filename)
                loadAsEdict(quiz, filename)
            else
                loadAsQuiz(quiz, filename)
            end
        end
    end		
end
