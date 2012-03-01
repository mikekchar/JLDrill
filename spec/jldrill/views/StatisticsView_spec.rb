# encoding: utf-8
require 'Context/Bridge'
require 'jldrill/contexts/ShowStatisticsContext'
require 'jldrill/model/Quiz'
require 'jldrill/views/test/StatisticsView'


module JLDrill

	describe ShowStatisticsContext::StatisticsView do
	
	    before(:each) do
			@context = JLDrill::ShowStatisticsContext.new(Context::Bridge.new(JLDrill::Test))
	        @context.createViews
	        @view = @context.mainView
	    end
	    
        it "should be able to update the statistics in the view" do
            quiz = Quiz.new
            @view.quiz.should be_nil
            @view.update(quiz)
            @view.quiz.should be(quiz)
        end
        
        it "should exit the context when the view is closed" do
            @context.should_receive(:exit)
            @view.close
        end
        
    end
end
