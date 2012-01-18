# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'
require 'Context/Publisher'
require 'jldrill/model/Config'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/model/items/JEDictionary'
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
require 'jldrill/contexts/LoadQuizContext'
require 'jldrill/contexts/LoadKanjiContext'
require 'jldrill/contexts/LoadTatoebaContext.rb'
require 'jldrill/contexts/AppendFileContext'
require 'jldrill/model/Acknowlegements'
require 'jldrill/contexts/ShowAboutContext'
require 'jldrill/contexts/ShowExamplesContext'
require 'jldrill/model/moji/Radical'
require 'jldrill/model/moji/Kanji'
require 'jldrill/model/moji/Kana'
require 'jldrill/model/Tanaka'
require 'jldrill/model/DeinflectionRules'

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :showStatisticsContext, :getFilenameContext,
	                :addNewVocabularyContext, :displayQuizStatusContext,
	                :displayProblemContext, :runCommandContext,
	                :showInfoContext, :showAllVocabularyContext,
                    :showAboutContext, :editVocabularyContext,
					:loadTanakaContext, :showExamplesContext,
                    :loadQuizContext, :loadKanjiContext,
                    :loadTatoebaContext, :appendFileContext,
	                :reference, :quiz, :kanji, :radicals, :kana,
                    :inTests, :tanaka, :tatoebaDB, :deinflect,
                    :longEventPublisher

	    attr_writer :quiz, :inTests, :reference
		
		def initialize(viewBridge)
			super(viewBridge)
			@runCommandContext = RunCommandContext.new(viewBridge)
			@loadReferenceContext = LoadReferenceContext.new(viewBridge)
			@setOptionsContext = SetOptionsContext.new(viewBridge)
			@showStatisticsContext = ShowStatisticsContext.new(viewBridge)
			@getFilenameContext = GetFilenameContext.new(viewBridge)
			@getFilenameContext.directory = Config::resolveDataFile(Config::QUIZ_DIR)
			@addNewVocabularyContext = AddNewVocabularyContext.new(viewBridge)
			@editVocabularyContext = EditVocabularyContext.new(viewBridge)
			@displayQuizStatusContext = DisplayQuizStatusContext.new(viewBridge)
			@displayProblemContext = DisplayProblemContext.new(viewBridge)
			@showInfoContext = ShowInfoContext.new(viewBridge)
			@showAllVocabularyContext = ShowAllVocabularyContext.new(viewBridge)
			@showAboutContext = ShowAboutContext.new(viewBridge)
			@loadTanakaContext = LoadTanakaContext.new(viewBridge)
            @loadTatoebaContext = LoadTatoebaContext.new(viewBridge)
			@showExamplesContext = ShowExamplesContext.new(viewBridge)
            @loadQuizContext = LoadQuizContext.new(viewBridge)
            @loadKanjiContext = LoadKanjiContext.new(viewBridge)
            @appendFileContext = AppendFileContext.new(viewBridge)
			@reference = JEDictionary.new
			@kanji = KanjiFile.new
			@radicals = RadicalFile.new
            @kana = KanaFile.new
			@quiz = Quiz.new
            # The quiz doesn't need to be saved
            @quiz.setNeedsSave(false)
            @inTests = false
			@tanaka = Tanaka::Reference.new
            @tatoebaDB = Tatoeba::Database.new
            @deinflect = DeinflectionRulesFile.new

            @longEventPublisher = Context::Publisher.new(self)
		end

        class MainWindowView < Context::View
            def inititalize(context)
                super(context)
            end

            # Destroy the main window
            def destroy
                # define in the concrete class
            end

            # Show the busy cursor in the UI if bool is true.
            # This happens during a long event where the user can't
            # interact with the window
            def showBusy(bool)
                # Please define in the concrete class
            end

            # This is a convenience method for the tests so that
            # they don't have to catch the exit on the context.
            def close
                context.exit
            end
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
                openFile(ARGV[0])
            end
        end

		def enter(parent)
			super(parent)
			@runCommandContext.enter(self)
			@displayProblemContext.enter(self)
			@displayQuizStatusContext.enter(self)
            parseCommandLineOptions
            @quiz.options.subscribe(self)
            loadKanji unless @inTests
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
		    if @quiz.file.empty?
		        saveAs
		    else
    		    if !@quiz.save
                    print "Error: Can't save.  Try again.\n"
                    saveAs
                end
    		end
		end
		
		def saveAs
		    filename = @getFilenameContext.enter(self, GetFilenameContext::SAVE)
		    if !filename.nil?
		        @quiz.file = filename
		        while !@quiz.save
                    print "Error: Can't save.  Try again.\n"
                end
		    end
		end

		def openFile(filename = nil)
            if !@loadQuizContext.isEntered?
                @loadQuizContext.onExit do
                    @quiz.options.subscribe(self)
                    optionsUpdated(@quiz.options)
                    @quiz.drill
                end
                @loadQuizContext.enter(self, @quiz, filename)
            end
		end
		
		def appendFile
            if !@appendFileContext.isEntered?
                @appendFileContext.onExit do
                    if quiz.currentProblem.nil?
                        quiz.drill
                    end
                end
                @appendFileContext.enter(self, @quiz)
            end
		end
		
		def promptForSaveAnd(&block)
		    if @quiz.needsSave?
		        promptForSave = PromptForSaveContext.new(@viewBridge) 
                result = promptForSave.enter(self)
		        if result == promptForSave.yes
                    save
		            block.call
                elsif result == promptForSave.no
                    block.call
                else
                    # Cancel... Do nothing
		        end
		    else
		        block.call
		    end
		end
		
        def createNew
            promptForSaveAnd do
                @quiz.reset
                # We need to resubscribe to the options in the new quiz
                # and realize that the options may have changed.
                @quiz.options.subscribe(self)
                optionsUpdated(@quiz.options)
                # New quizes don't need to be saved.
                @quiz.setNeedsSave(false)
                @quiz.updateLoad
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
            if !@loadReferenceContext.isEntered?
                @loadReferenceContext.enter(self, @reference, @deinflect, 
                                            @quiz.options)
            end
		end

        def exampleDB
            if @tanaka.loaded?
                return @tanaka
            else
                return @tatoebaDB
            end
        end

		def loadTanaka
			if @tanaka.loaded?
                if !@showExamplesContext.isEntered?
                    @showExamplesContext.enter(self)
                end
			else
                if !@loadTanakaContext.isEntered?
                    @loadTanakaContext.onExit do
                        @showExamplesContext.enter(self)
                    end
                    @loadTanakaContext.enter(self, @tanaka, @quiz.options)
                end
			end
		end

		def loadTatoeba
			if @tatoebaDB.loaded?
                if !@showExamplesContext.isEntered?
                    @showExamplesContext.enter(self)
                end
			else
                if !@loadTatoebaContext.isEntered?
                    @loadTatoebaContext.onExit do
                        @showExamplesContext.enter(self)
                    end
                    @loadTatoebaContext.enter(self, @tatoebaDB)
                end
			end
		end

		
		def loadKanji
            if !@loadKanjiContext.isEntered?
                @loadKanjiContext.enter(self, @kanji, @radicals, @kana)
            end
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
                @showExamplesContext.showAnswer if @showExamplesContext.isEntered?
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
		    @quiz.resetContents
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

        def startLongEvent()
            @mainView.showBusy(true)
            @longEventPublisher.update("startLongEvent")
        end

        def stopLongEvent()
            @mainView.showBusy(false)
            @longEventPublisher.update("stopLongEvent")
        end
    end
end
