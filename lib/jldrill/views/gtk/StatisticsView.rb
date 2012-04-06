# encoding: utf-8
require 'jldrill/views/gtk/widgets/StatisticsWindow'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/model/Quiz'
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
            reviewTable = quiz.contents.reviewSet.scheduleTable
		    @statisticsWindow.updateReviewDuration(reviewTable)
		    @statisticsWindow.updateReviewAccuracy(quiz.contents.reviewSet.stats)
		    @statisticsWindow.updateReviewRate(quiz.contents.stats)
            
            forgottenTable = quiz.contents.forgottenSet.scheduleTable
		    @statisticsWindow.updateForgottenDuration(forgottenTable)
		    @statisticsWindow.updateForgottenAccuracy(quiz.contents.forgottenSet.stats)
		    @statisticsWindow.updateForgottenRate(quiz.contents.stats)
		end
        
        def showBusy(bool)
            @statisticsWindow.showBusy(bool)
        end
    end   
end
