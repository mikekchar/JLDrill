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
require 'jldrill/contexts/ShowInfoContext'
require 'jldrill/contexts/ShowAllVocabularyContext'
require 'jldrill/model/Acknowlegements'
require 'jldrill/contexts/ShowAboutContext'
require 'jldrill/model/moji/Radical'
require 'jldrill/model/moji/Kanji'
require 'jldrill/model/moji/Kana'

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :showStatisticsContext, :getFilenameContext,
	                :addNewVocabularyContext, :displayQuizStatusContext,
	                :displayProblemContext, :runCommandContext,
	                :showInfoContext, :showAllVocabularyContext,
                    :showAboutContext, :editVocabularyContext,
	                :reference, :quiz, :kanji, :radicals, :kana,
                    :inTests

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
			@reference = HashedEdict.new
			@kanji = nil
			@radicals = nil
            @kana = nil
			@quiz = Quiz.new
            @inTests = false
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

		def enter(parent)
			super(parent)
			@mainView.open
            loadKanji unless @inTests
			@runCommandContext.enter(self)
			@displayProblemContext.enter(self)
			@displayQuizStatusContext.enter(self)
		end
				
		def exit
			@runCommandContext.exit
		    @displayQuizStatusContext.exit 
		    @displayProblemContext.exit 
			@parent.exit
			super
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
				
		def loadQuiz(quiz)
		    filename = @getFilenameContext.enter(self)
		    if !filename.nil?
                if JLDrill::Quiz.drillFile?(filename)
                    quiz.load(filename)
                else
                    dict = Edict.new(filename)
                    dict.read
                    quiz.loadFromDict(dict)
                end
                true
            else
                false
            end
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
		    if !@quiz.currentProblem.nil?
    		    @editVocabularyContext.enter(self) unless @editVocabularyContext.isEntered?
    		end
		end

        def editItem(item)
            if !item.nil?
                @quiz.createProblem(item)
                editVocabulary
            end
        end

		def updateQuizStatus
		    @displayQuizStatusContext.quizUpdated(@quiz) if @displayQuizStatusContext.isEntered?
		end
		
		def showAnswer
		    @displayProblemContext.showAnswer if @displayProblemContext.isEntered?
		end
		
		def correct
		    @quiz.correct
		    @quiz.drill
		end
		
		def incorrect
		    @quiz.incorrect
		    @quiz.drill
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
