# encoding: utf-8
require 'Context/Spec'
require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

# To see an example for creating a new context class, please see
# Context::Spec::ContextStory::TestContext
module Context::Spec::ContextStory

    # This is an example of a Context.
    # To make a Context, simply derive it from the base Context class.
    # You will have to override some methods as described below.
    class TestContext < Context::Context
        
        # The initialize method must always call super(bridge)
        # after that you can add any other initialization that
        # you want (including creating other sub Contexts).
        def initialize(bridge)
            super(bridge)
        end
        
        # You must also override createViews() to create a new
        # new view and assign it to the variable @mainView.
        # You can create more than one view, but one must
        # be chosen as the main view.
        def createViews
            @mainView = Context::View.new(self)
        end
        
        # Finally, you must usually override the destroyViews()
        # method.  First you should call the method that
        # will clean up the concreate view structures.  Then
        # you should set the variable @mainView to nil
        def destroyViews
            # In this example, I am only using the abstract
            # view class, so there is no need to clean anything
            # up.  I'll just set the mainView to nil
            @mainView = nil
        end
        
    end
    
    describe Context::Context do
        
        before(:each) do
            @bridge = Context::Bridge.new(Context::Context)
            @parent = TestContext.new(@bridge)
            @context = TestContext.new(@bridge)
        end
		
        it "should not have a parent set on creation" do
            expect(@context.parent).to be_nil
        end
		
        it "should set the parent on entry" do
            @parent.createViews
            expect(@parent).to receive(:addView)
            @context.enter(@parent)
            expect(@context.parent).to equal(@parent)
        end
		
        it "should add new views to the main view" do
            newContext = TestContext.new(@bridge)
            newContext.createViews
            @context.createViews
            expect(@context.mainView).to receive(:addView).with(newContext.mainView)
            
            @context.addView(newContext.mainView)
        end
        
        it "should remove views on exit" do
            @parent.createViews
            expect(@parent.mainView).to receive(:removeView).with(@context.peekAtView)
            expect(@parent).to receive(:addView)
            @context.enter(@parent)
            @context.exit
        end
        
        it "should create the views on entry" do
            @context.should_receive(:setupViews) do
                @context.createViews
            end
            @parent.should_receive(:addView)
            @parent.createViews
            @context.enter(@parent)
        end
        
        it "should destroy the views on exit" do
            @parent.createViews
            @context.should_receive(:setupViews).exactly(2).times do
                @context.createViews
            end
            @parent.should_receive(:addView)
            @context.enter(@parent)
            @parent.mainView.should_receive(:removeView).with(@context.peekAtView)
            @context.should_receive(:destroyViews)
            @context.exit
        end
        
        it "should keep track if the context has been entered or not" do
            @parent.createViews            
            @context.should_receive(:setupViews).exactly(2).times do
                @context.createViews
            end
            @parent.should_receive(:addView)
            @context.isEntered?.should be(false)
            @context.enter(@parent)
            @context.isEntered?.should be(true)
            @parent.mainView.should_receive(:removeView).with(@context.peekAtView)
            @context.should_receive(:destroyViews)
            @context.exit
            @context.isEntered?.should be(false)
        end
    end
end

