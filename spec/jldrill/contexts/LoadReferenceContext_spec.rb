require 'jldrill/contexts/LoadReferenceContext'
require 'Context/Bridge'

module JLDrill

	# Redefine the thread code so that it doesn't spawn an
	# actual thread
	def Thread.new(&block)
	    if !@timesInvoked
	        @timesInvoked = 1
	    else
	        @timesInvoked += 1
	    end
	    block.call
	end
	
	def Thread.timesInvoked
	    if !@timesInvoked
	        0
	    else
	        @timesInvoked
	    end
	end
	
	def Thread.reset
	    @timesInvoked = 0
	end


	describe LoadReferenceContext do

		before(:each) do
			@main = MainContext.new(Context::Bridge.new(JLDrill))
			@context = @main.loadReferenceContext
			Thread.reset
		end
		
		it "should redefine Thread.new for testing" do
			Thread.timesInvoked.should be(0)
			
		    Thread.new do
			    # Nothing
		    end
		    
		    Thread.timesInvoked.should be(1)
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
            Thread.timesInvoked.should be(1)
            @context.reference.should be(@main.reference)
            @context.reference.file.should be(@context.filename)
        end
        
        it "should automatically exit the context after the loading is finished" do
            @main.reference.should_receive(:read)
            @context.should_receive(:exit)
            @context.enter(@main)
            Thread.timesInvoked.should be(1)
        end

        it "should update the view when reading" do
            # I'm not totally satisfied with this test, but it's the only
            # way I could think to do it.
            reference = @main.reference
            def reference.read(&block)
                block.call(10)
            end
            @context.mainView.should_receive(:update)
            @context.enter(@main)            
        end

        it "should have a view" do
            @context.mainView.should_not be_nil
        end
        
	end
end
