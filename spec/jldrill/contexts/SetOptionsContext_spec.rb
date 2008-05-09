require 'jldrill/contexts/SetOptionsContext'
require 'Context/ViewFactory'
require 'jldrill/model/Quiz/Quiz'

module JLDrill

	describe SetOptionsContext do

		before(:each) do
			@main = MainContext.new(Context::ViewFactory.new(JLDrill))
			@context = @main.setOptionsContext
		end

        it "should be created by the main context" do
            @main.setOptionsContext.should_not be_nil
        end

        
        it "should have a view" do
            @context.mainView.should_not be_nil
        end
        
        it "should update with the parent's quiz" do
            @context.quiz.should be(nil)
            @main.quiz = Quiz.new
            @main.quiz.should_not be(nil)
            @context.mainView.should_receive(:update).with(@main.quiz.options)
            @context.enter(@main)
        end
	end
end
