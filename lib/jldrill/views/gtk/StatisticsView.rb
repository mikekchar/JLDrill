require 'jldrill/views/gtk/widgets/StatisticsWindow'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/model/Quiz/Quiz'
require 'gtk2'

module JLDrill::Gtk
	class StatisticsView < JLDrill::ShowStatisticsContext::StatisticsView
        attr_reader :statisticsWindow
        	
		def initialize(context)
			super(context)
			@statisticsWindow = StatisticsWindow.new(self)
		end
		
		def getWidget
			@statisticsWindow
		end
		
        def destroy
            @statisticsWindow.explicitDestroy
        end
		
		def emitDestroyEvent
			@statisticsWindow.signal_emit("destroy")
		end
		
		def update(quiz)
		    super(quiz)
            table = quiz.strategy.stats.statsTable
		    @statisticsWindow.updateDuration(table)
		    @statisticsWindow.updateAccuracy(quiz.strategy.stats)
		    @statisticsWindow.updateRate(quiz.strategy.stats)
		end
    end   
end
