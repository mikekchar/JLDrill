require 'Context/Context'
require 'Context/Key'
require 'Context/Bridge'
require 'jldrill/views/MainWindowView'
require 'jldrill/model/HashedEdict'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/contexts/SetOptionsContext'
require 'jldrill/contexts/ShowStatisticsContext'

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :showStatisticsContext, :reference, :quiz
	    attr_writer :quiz
		
		def initialize(viewBridge)
			super(viewBridge)
			@mainWindowView = viewBridge.MainWindowView.new(self)
			@mainView = @mainWindowView
			@loadReferenceContext = LoadReferenceContext.new(viewBridge)
			@setOptionsContext = SetOptionsContext.new(viewBridge)
			@showStatisticsContext = ShowStatisticsContext.new(viewBridge)
			@reference = HashedEdict.new
			@quiz = nil
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
		
		def loadReference
		    @loadReferenceContext.enter(self) unless @loadReferenceContext.isEntered?
		end
		
		def setOptions
		    @setOptionsContext.enter(self) unless @setOptionsContext.isEntered?
		end
		
		def showStatistics
		    @showStatisticsContext.enter(self) unless @showStatisticsContext.isEntered?
		end
    end
end
