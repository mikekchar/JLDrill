require 'Context/Context'
require 'Context/Key'
require 'Context/Bridge'
require 'jldrill/views/MainWindowView'
require 'jldrill/model/Edict/Edict'
require 'jldrill/model/HashedEdict'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/contexts/SetOptionsContext'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/contexts/GetFilenameContext'
require 'jldrill/contexts/AddNewVocabularyContext'
require 'jldrill/contexts/DisplayQuizStatusContext'
require 'jldrill/contexts/DisplayProblemContext'

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :showStatisticsContext, :getFilenameContext,
	                :addNewVocabularyContext, :displayQuizStatusContext,
	                :displayProblemContext,
	                :reference, :quiz
	    attr_writer :quiz
		
		def initialize(viewBridge)
			super(viewBridge)
			@loadReferenceContext = LoadReferenceContext.new(viewBridge)
			@setOptionsContext = SetOptionsContext.new(viewBridge)
			@showStatisticsContext = ShowStatisticsContext.new(viewBridge)
			@getFilenameContext = GetFilenameContext.new(viewBridge)
			@getFilenameContext.directory = File.join(JLDrill::Config::DATA_DIR, "quiz")
			@addNewVocabularyContext = AddNewVocabularyContext.new(viewBridge)
			@displayQuizStatusContext = DisplayQuizStatusContext.new(viewBridge)
			@displayProblemContext = DisplayProblemContext.new(viewBridge)
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
			# The quiz status is always displayed
			@displayProblemContext.enter(self)
			@displayQuizStatusContext.enter(self)
		end
				
		def exit
			super
		    @displayQuizStatusContext.exit 
		    @displayProblemContext.exit 
			@parent.exit
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
		
		def updateQuizStatus
		    @displayQuizStatusContext.quizUpdated(@quiz) if @displayQuizStatusContext.isEntered?
		end
		
		def updateNewProblemStatus
		    @displayQuizStatusContext.newProblemUpdated(@quiz) if @displayQuizStatusContext.isEntered?
		end
		
		def showAnswer
		    @displayProblemContext.showAnswer if @displayProblemContext.isEntered?
		end
    end
end
