# encoding: utf-8
require 'Context/Bridge'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/views/gtk/StatisticsView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/model/Quiz/Quiz'


module JLDrill::Gtk

	describe StatisticsView do

        before(:all) do
            @story = JLDrill::StoryMemento.new("StatisticsView")

            def @story.setup(type)
                super(type)
                @context = @mainContext.showStatisticsContext
                @view = @context.peekAtView
            end
        end

        it "should close the view when the window is destroyed" do
            @story.setup(JLDrill::Gtk)
            @story.start
            @story.mainContext.showStatistics
            @story.view.should_receive(:close) do
                @story.view.statisticsWindow.destroy
            end
            @story.view.emitDestroyEvent
            @story.shutdown
        end
        
	end
end
