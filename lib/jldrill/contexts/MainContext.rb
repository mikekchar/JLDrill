require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/MainWindowView'
require 'jldrill/model/items/edict/Edict'
require 'jldrill/model/items/edict/HashedEdict'
require 'jldrill/contexts/RunCommandContext'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/contexts/SetOptionsContext'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/contexts/GetFilenameContext'
require 'jldrill/contexts/AddNewVocabularyContext'
require 'jldrill/contexts/EditVocabularyContext'
require 'jldrill/contexts/DisplayQuizStatusContext'
require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/contexts/PromptForSaveContext'
require 'jldrill/contexts/PromptForDeleteContext'
require 'jldrill/contexts/ShowInfoContext'
require 'jldrill/contexts/ShowAllVocabularyContext'
require 'jldrill/contexts/LoadTanakaContext'
require 'jldrill/model/Acknowlegements'
require 'jldrill/contexts/ShowAboutContext'
require 'jldrill/contexts/ShowExamplesContext'
require 'jldrill/model/moji/Radical'
require 'jldrill/model/moji/Kanji'
require 'jldrill/model/moji/Kana'
require 'jldrill/model/Tanaka'

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :showStatisticsContext, :getFilenameContext,
	                :addNewVocabularyContext, :displayQuizStatusContext,
	                :displayProblemContext, :runCommandContext,
	                :showInfoContext, :showAllVocabularyContext,
                    :showAboutContext, :editVocabularyContext,
					:loadTanakaContext, :showExamplesContext,
	                :reference, :quiz, :kanji, :radicals, :kana,
                    :inTests, :tanaka

	    attr_writer :quiz, :inTests
		
		def initialize(viewBridge)
			super(viewBridge)
			@runCommandContext = RunCommandContext.new(viewBridge)
			@loadReferenceContext = LoadReferenceContext.new(viewBridge)
			@setOptionsContext = SetOptionsContext.new(viewBridge)
			@showStatisticsContext = ShowStatisticsContext.new(viewBridge)
			@getFilenameContext = GetFilenameContext.new(viewBridge)
			@getFilenameContext.directory = File.join(JLDrill::Config::DATA_DIR, "quiz")
			@addNewVocabularyContext = AddNewVocabularyContext.new(viewBridge)
			@editVocabularyContext = EditVocabularyContext.new(viewBridge)
			@displayQuizStatusContext = DisplayQuizStatusContext.new(viewBridge)
			@displayProblemContext = DisplayProblemContext.new(viewBridge)
			@showInfoContext = ShowInfoContext.new(viewBridge)
			@showAllVocabularyContext = ShowAllVocabularyContext.new(viewBridge)
			@showAboutContext = ShowAboutContext.new(viewBridge)
			@loadTanakaContext = LoadTanakaContext.new(viewBridge)
			@showExamplesContext = ShowExamplesContext.new(viewBridge)
			@reference = HashedEdict.new
			@kanji = nil
			@radicals = nil
            @kana = nil
			@quiz = Quiz.new
            # The quiz doesn't need to be saved
            @quiz.setNeedsSave(false)
            @inTests = false
			@tanaka = Tanaka.new
		end
		
		def createViews
			@mainWindowView = @viewBridge.MainWindowView.new(self)
			@mainView = @mainWindowView		    
		end
		
		def destroyViews
		    @mainWindowView.destroy unless @mainWindowView.nil?
		    @mainWindowView = nil
		    @mainView = nil
		end

        def parseCommandLineOptions
            if ARGV.size == 1
                if loadFile(ARGV[0])
                    @quiz.drill
                end
            end
        end

		def enter(parent)
			super(parent)
			@mainView.open
            loadKanji unless @inTests
			@runCommandContext.enter(self)
			@displayProblemContext.enter(self)
			@displayQuizStatusContext.enter(self)
            parseCommandLineOptions
            @quiz.options.subscribe(self)
		end
				
		def exit
			@runCommandContext.exit
		    @displayQuizStatusContext.exit 
		    @displayProblemContext.exit 
            @quiz.options.unsubscribe(self)
			@parent.exit
			super
		end

        def optionsUpdated(options)
            if options.autoloadDic
                loadReference
            end
        end
		
        def save
		    if @quiz.savename.empty?
		        saveAs
		    else
    		    if !@quiz.save
                    print "Error: Can't save.  Try again.\n"
                    saveAs
                end
    		end
		end
		
		def saveAs
		    filename = @getFilenameContext.enter(self)
		    if !filename.nil?
		        @quiz.savename = filename
		        while !@quiz.save
                    print "Error: Can't save.  Try again.\n"
                end
		    end
		end

        def loadFile(filename)
		    if !filename.nil?
                if JLDrill::Quiz.drillFile?(filename)
                    quiz.load(filename)
                else
                    dict = Edict.new(filename)
                    dict.read
                    quiz.loadFromDict(dict)
                end
                # We need to resubscribe to the options in the new quiz
                # and realize that the options may have changed.
                @quiz.options.subscribe(self)
                optionsUpdated(@quiz.options)
                # We've just loaded the file, so it doesn't need to be saved
                @quiz.setNeedsSave(false)
                return true
            else
                return false
            end
        end	
				
		def loadQuiz(quiz)
		    filename = @getFilenameContext.enter(self)
            return loadFile(filename)
		end
		
		def openFile
		    if loadQuiz(@quiz)
		        @quiz.drill
            end
		end
		
		def appendFile
		    newQuiz = Quiz.new
		    if loadQuiz(newQuiz)
                @quiz.append(newQuiz)
		    end
		end
		
		def promptForSaveAnd(&block)
		    if @quiz.needsSave?
		        promptForSave = PromptForSaveContext.new(@viewBridge) 
		        if promptForSave.enter(self) != promptForSave.cancel
		            block.call
		        end
		    else
		        block.call
		    end
		end
		
        def createNew
            promptForSaveAnd do
                @quiz.setup
                # We need to resubscribe to the options in the new quiz
                # and realize that the options may have changed.
                @quiz.options.subscribe(self)
                optionsUpdated(@quiz.options)
                # New quizes don't need to be saved.
                @quiz.setNeedsSave(false)
            end
        end

		def open
		    promptForSaveAnd do
		        openFile
		    end
		end
		
		def quit
		    promptForSaveAnd do
		        exit
		    end
		end
		
		def loadReference
		    @loadReferenceContext.enter(self) unless @loadReferenceContext.isEntered?
		end

		def loadTanaka
			if @tanaka.loaded?
				@showExamplesContext.enter(self) unless @showExamplesContext.isEntered?
			else
				@loadTanakaContext.enter(self) unless @loadTanakaContext.isEntered?
			end
		end

		
		def loadKanji
		    kanjiFile = Config::getDataDir + "/dict/rikaichan/kanji.dat"
            radicalsFile = Config::getDataDir + "/dict/rikaichan/radicals.dat"
            kanaFile = Config::getDataDir + "/dict/Kana/kana.dat"
		    @radicals = RadicalList.fromFile(radicalsFile)
			@kanji = KanjiList.fromFile(kanjiFile)
            @kana = KanaList.fromFile(kanaFile)
		end
		
		def setOptions
		    @setOptionsContext.enter(self) unless @setOptionsContext.isEntered?
		end
		
		def showStatistics
		    @showStatisticsContext.enter(self) unless @showStatisticsContext.isEntered?
		end
		
		def setReviewMode(bool)
		    @quiz.options.reviewMode = bool unless @quiz.nil?
		end
		
		def addNewVocabulary
		    @addNewVocabularyContext.enter(self) unless @addNewVocabularyContext.isEntered?
		end
		
		def editVocabulary
		    if !@quiz.currentProblem.nil? &&
                    !@quiz.currentProblem.preview?
                # Always show the answer before editing the problem
                showAnswer
    		    @editVocabularyContext.enter(self) unless @editVocabularyContext.isEntered?
    		end
		end

        def deleteVocabulary
		    if !@quiz.currentProblem.nil? &&
                    !@quiz.currentProblem.preview?
                # Always show the answer before deleting an item
                showAnswer
                prompt = PromptForDeleteContext.new(@viewBridge)
                if prompt.enter(self) == prompt.yes
                    item = @quiz.currentProblem.item
                    @quiz.deleteItem(item)
                    drill
                end
            end
        end

        # Display the problem if it isn't the current one
        def displayItem(item)
            if !item.nil?
                if @quiz.currentProblem.nil? || 
                        !@quiz.currentProblem.item.eql?(item)
                    @quiz.displayProblem(item)
                    showAnswer
                end
            end
        end

        # Preview an item that doesn't currently exist in the quiz
        def previewItem(item)
            if !item.nil?
                if @quiz.currentProblem.nil? || 
                        !@quiz.currentProblem.item.eql?(item)
                    @quiz.previewProblem(item)
                    showAnswer
                end
            end
        end
        
        def editItem(item)
            if !item.nil?
                displayItem(item)
                editVocabulary
            end
        end

        def deleteItem(item)
            if !item.nil?
                displayItem(item)
                deleteVocabulary
            end
        end

		def updateQuizStatus
		    @displayQuizStatusContext.quizUpdated(@quiz) if @displayQuizStatusContext.isEntered?
		end
		
		def showAnswer
            if !@quiz.currentProblem.nil?
                @displayProblemContext.showAnswer if @displayProblemContext.isEntered?
            end
		end
		
        # Get a new problem in the drill without answering the current problem
        def drill
            @quiz.drill
        end

		def correct
            if !@quiz.currentProblem.nil? && !@quiz.currentProblem.displayOnly?
                @quiz.correct
                @quiz.drill
            end
		end
		
		def incorrect
            if !@quiz.currentProblem.nil? && !@quiz.currentProblem.displayOnly?
                @quiz.incorrect
                @quiz.drill
            end
		end

        def learn
            if !@quiz.currentProblem.nil? && !@quiz.currentProblem.displayOnly?
                @quiz.learn
                @quiz.drill
            end
        end

        def removeDups
            if !quiz.nil?
                @quiz.contents.removeDuplicates
            end
        end
		
		def reset
		    @quiz.reset
		end
		
		def showQuizInfo
		    @showInfoContext.enter(self, @quiz.info) unless @showInfoContext.isEntered?
		end

		def showAcknowlegements
		    @showInfoContext.enter(self, Acknowlegements) unless @showInfoContext.isEntered?
		end
		
		def showAllVocabulary
		    @showAllVocabularyContext.enter(self) unless @showAllVocabularyContext.isEntered?
		end

		def showAbout
		    @showAboutContext.enter(self) unless @showAboutContext.isEntered?
		end
    end
end
