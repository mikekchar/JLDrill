require 'jldrill/contexts/SetOptionsContext'
require 'Context/Bridge'
require 'jldrill/model/Quiz/Quiz'

module JLDrill

	describe SetOptionsContext do

		before(:each) do
			@main = MainContext.new(Context::Bridge.new(JLDrill))
			@context = @main.setOptionsContext
			@context.createViews
			@view = @context.mainView
			
    		def @context.createViews
	    	    # Use the previously set View
    		end

		end
		
        it "should be created by the main context" do
            @main.setOptionsContext.should_not be_nil
        end
        
        it "should update the view with the parent's quiz options on entry" do
            @context.quiz.should be(nil)
            @main.quiz = Quiz.new
            @main.quiz.should_not be(nil)
            @view.should_receive(:update).with(@main.quiz.options)
            @context.enter(@main)
        end
        
        it "should update the parent's quiz options with the views options on exit" do
            @context.quiz.should be(nil)
            @main.quiz = Quiz.new
            @main.quiz.should_not be(nil)
            @main.quiz.options.should_receive(:assign).with(@view.options)
            # Pretend that the options got set
            @view.optionsSet = true
            @context.enter(@main)
            # Note: enter automatically calls exit            
        end

        it "should not update the parent's quiz options when cancelled" do
            @context.quiz.should be(nil)
            @main.quiz = Quiz.new
            @main.quiz.should_not be(nil)
            @main.quiz.options.should_not_receive(:assign)
            # Pretend that the options did not get set
            @view.optionsSet = false
            @context.enter(@main)
            # Note: enter automatically calls exit            
        end
        
	end
end
