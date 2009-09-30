require 'jldrill/views/gtk/widgets/StatisticsWindow.rb'
require 'jldrill/views/StatisticsView'
require 'jldrill/model/Quiz/Quiz'
require 'gtk2'

module JLDrill::Gtk
	class StatisticsView < JLDrill::StatisticsView
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
		    @statisticsWindow.updateSchedule(quiz.strategy.stats)
		    @statisticsWindow.updateDuration(quiz.strategy.stats)
		    @statisticsWindow.updateAccuracy(quiz.strategy.stats)
		    @statisticsWindow.updateRate(quiz.strategy.stats)
		end
    end   
end
