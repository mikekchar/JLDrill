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

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :showStatisticsContext, :getFilenameContext, 
	                :reference, :quiz
	    attr_writer :quiz
		
		def initialize(viewBridge)
			super(viewBridge)
			@mainWindowView = viewBridge.MainWindowView.new(self)
			@mainView = @mainWindowView
			@loadReferenceContext = LoadReferenceContext.new(viewBridge)
			@setOptionsContext = SetOptionsContext.new(viewBridge)
			@showStatisticsContext = ShowStatisticsContext.new(viewBridge)
			@getFilenameContext = GetFilenameContext.new(viewBridge)
			@getFilenameContext.directory = File.join(JLDrill::Config::DATA_DIR, "quiz")
			@reference = HashedEdict.new
			@quiz = Quiz.new
		end
		
		def enter(parent)
			super(parent)
			@mainWindowView.open 
		end
		
		def exit
			@parent.exit
		end
				
		def close
			exit
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
                @mainWindowView.displayQuestion(@quiz.drill)
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
    end
end
