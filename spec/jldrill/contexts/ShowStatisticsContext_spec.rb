# encoding: utf-8
require 'jldrill/contexts/ShowStatisticsContext'
require 'Context/Bridge'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/VocabularyView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill

	describe ShowStatisticsContext do

		before(:each) do
			@main = MainContext.new(Context::Bridge.new(JLDrill::Test))
            @main.inTests = true
			@main.createViews
			@main.quiz = Quiz.new
			@context = @main.showStatisticsContext
			@context.createViews
			@view = @context.mainView
			
    		def @context.createViews
	    	    # Use the previously set View
    		end
		end
		
        it "should be created by the main context" do
            @main.showStatisticsContext.should_not be_nil
        end
        
        it "should have a view" do
            @view.should_not be_nil
        end
        
        it "should not be able to create the context twice at once" do
            @main.mainView.should_receive("addView").exactly(1).times
            @main.showStatistics
            @main.showStatistics
        end
        
        it "should not show statistics if there is no quiz" do
            @main.mainView.should_not_receive(:addView)
            # 3 cases: No parent context, parent doesn't have quiz, parent's quiz is nil
            @context.enter(nil)
            @context.enter(Context::Context.new(mock("ViewBridge")))
            @main.quiz = nil
            @context.enter(@main)
        end
        
        it "should update the view with the parent's quiz statistics on entry" do
            @view.should_receive(:update).with(@main.quiz)
            @context.enter(@main)
        end


	end
end
