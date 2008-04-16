require 'jldrill/contexts/LoadReferenceContext'
require 'Context/ViewFactory'

module JLDrill

	describe LoadReferenceContext do

		before(:each) do
			@main = MainContext.new(Context::ViewFactory.new(JLDrill))
			@context = @main.loadReferenceContext
		end

        it "should be created by the main context" do
            @main.loadReferenceContext.should_not be_nil
        end
        
        it "should have a hard coded filename" do
            @context.filename.should_not be_nil
            File.exists?(@context.filename).should be(true)
        end
        
        it "should load the parents reference dictionary on entry" do
            @context.reference.should be(nil)
            @main.reference.should_not be(nil)
            @main.reference.should_receive(:read)
            @context.enter(@main)
            @context.reference.should be(@main.reference)
            @context.reference.file.should be(@context.filename)
        end
	end
end
