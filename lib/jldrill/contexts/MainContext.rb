require 'Context/Context'
require 'Context/Key'
require 'Context/Bridge'
require 'jldrill/views/MainWindowView'
require 'jldrill/model/Edict/Edict'
require 'jldrill/model/HashedEdict'
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
require 'jldrill/contexts/ShowQuizInfoContext'
require 'jldrill/contexts/ShowAllVocabularyContext'

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :showStatisticsContext, :getFilenameContext,
	                :addNewVocabularyContext, :displayQuizStatusContext,
	                :displayProblemContext, :runCommandContext,
	                :showQuizInfoContext, :showAllVocabularyContext,
	                :reference, :quiz
	    attr_writer :quiz
		
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
			@showQuizInfoContext = ShowQuizInfoContext.new(viewBridge)
			@showAllVocabularyContext = ShowAllVocabularyContext.new(viewBridge)
			@reference = HashedEdict.new
			@quiz = Quiz.new
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
			@runCommandContext.enter(self)
			@displayProblemContext.enter(self)
			@displayQuizStatusContext.enter(self)
		end
				
		def exit
			super
			@runCommandContext.exit
		    @displayQuizStatusContext.exit 
		    @displayProblemContext.exit 
			@parent.exit
		end
		
		def save
		    if @quiz.savename.empty?
		        saveAs
		    else
    		    @quiz.save
    		end
		end
		
		def saveAs
		    filename = @getFilenameContext.enter(self)
		    if !filename.nil?
		        @quiz.savename = filename
		        @quiz.save
		    end
		end
				
		def loadQuiz(quiz)
		    filename = @getFilenameContext.enter(self)
		    if !filename.nil?
                if JLDrill::Quiz.drillFile?(filename)
                    quiz.load(filename)
                else
                    quiz.loadFromDict(Edict.new(filename).read)
                end
                if quiz = @quiz
                    @mainWindowView.updateQuiz
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
		    @editVocabularyContext.enter(self) unless @editVocabularyContext.isEntered?
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
		    @showQuizInfoContext.enter(self) unless @showQuizInfoContext.isEntered?
		end
		
		def showAllVocabulary
		    @showAllVocabularyContext.enter(self) unless @showAllVocabularyContext.isEntered?
		end
    end
end
