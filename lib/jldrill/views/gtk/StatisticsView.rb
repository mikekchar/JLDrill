# encoding: utf-8
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
            reviewTable = quiz.strategy.reviewStats.statsTable
		    @statisticsWindow.updateReviewDuration(reviewTable)
		    @statisticsWindow.updateReviewAccuracy(quiz.strategy.reviewStats)
		    @statisticsWindow.updateReviewRate(quiz.strategy.reviewStats)
            
            forgottenTable = quiz.strategy.forgottenStats.statsTable
		    @statisticsWindow.updateForgottenDuration(forgottenTable)
		    @statisticsWindow.updateForgottenAccuracy(quiz.strategy.forgottenStats)
		    @statisticsWindow.updateForgottenRate(quiz.strategy.forgottenStats)
		end
    end   
end
