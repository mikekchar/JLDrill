# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/model/items/JEDictionary'
require 'jldrill/model/items/CEDictionary'
require 'jldrill/contexts/LoadFileContext'
require 'jldrill/contexts/GetFilenameContext'
require 'jldrill/contexts/LoadQuizFromEdictContext.rb'

module JLDrill

	class LoadQuizContext < Context::Context

        attr_reader :getFilenameContext
		
		def initialize(viewBridge)
			super(viewBridge)
            @loadFileContext = LoadFileContext.new(@viewBridge)
            @getFilenameContext = GetFilenameContext.new(@viewBridge)
            # Set the initial directory to the quiz Data dir
			@getFilenameContext.directory = Config::resolveDataFile(Config::QUIZ_DIR)
            @loadQuizFromEdictContext = LoadQuizFromEdictContext.new(@viewBridge)
            @filename = nil
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
            if quiz.options.language == "Chinese"
                edict = CEDictionary.new
            else
                edict = JEDictionary.new
            end
            @loadFileContext.onExit do
                @loadQuizFromEdictContext.onExit do
                    exitLoadQuizContext
                end
                @loadQuizFromEdictContext.enter(self, quiz, edict)
            end
            @loadFileContext.enter(self, edict, filename)
        end

        def loadAsQuiz(quiz, filename)
            @loadFileContext.onExit do
                exitLoadQuizContext
            end
            @loadFileContext.enter(self, quiz, filename)
        end

        def enter(parent, quiz, filename=nil)
            super(parent)
            if filename.nil?
                filename = @getFilenameContext.enter(self, 
                                                     GetFilenameContext::OPEN)
            end
            if filename.nil?
                exitLoadQuizContext
            else
                if !JLDrill::Quiz.drillFile?(filename)
                    loadAsEdict(quiz, filename)
                else
                    loadAsQuiz(quiz, filename)
                end
            end
        end
    end		
end
