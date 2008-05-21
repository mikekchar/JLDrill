require 'Context/Context'
require 'Context/Key'
require 'Context/Bridge'
require 'jldrill/views/MainWindowView'
require 'jldrill/model/HashedEdict'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/contexts/SetOptionsContext'

module JLDrill

	class MainContext < Context::Context
	
	    attr_reader :loadReferenceContext, :setOptionsContext, 
	                :reference, :quiz
	    attr_writer :quiz
		
		def initialize(viewBridge)
			super(viewBridge)
			@mainWindowView = viewBridge.MainWindowView.new(self)
			@mainView = @mainWindowView
			@loadReferenceContext = LoadReferenceContext.new(viewBridge)
			@setOptionsContext = SetOptionsContext.new(viewBridge)
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
		    @loadReferenceContext.enter(self)
		end
		
		def setOptions
		    @setOptionsContext.enter(self)
		end
    end
end
