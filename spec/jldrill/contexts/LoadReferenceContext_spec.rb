require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'Context/Bridge'

module JLDrill

	describe LoadReferenceContext do

        before(:all) do
            @story = JLDrill::StoryMemento.new("LoadReferenceContext")

            def @story.setup(type)
                super(type)
                @context = @mainContext.loadReferenceContext
			    def @context.reset
			        @timesInvoked = 0
			        @counter = 0
			    end
			    def @context.runInBackground(&block)
			        @timesInvoked += 1
			        super
			    end
			    def @context.timesInvoked
			        @timesInvoked
			    end
			    def @context.incCounter
			        @counter += 1
			    end
			    def @context.count
			        @counter
			    end
			    @context.reset
                @view = @context.peekAtView
            end
		end
		
		it "should have a way to count the times invoked in the tests" do
		# Don't know how to test this reliably.  This test passes, but probably
		# just on my machine...
#		    @story.setup(JLDrill::Gtk)
#		    @story.start
#		    @story.context.timesInvoked.should be(0)
#		    @story.context.runInBackground do
#                1.upto(100000) do |i|
#                    @story.context.incCounter
#                end
#		    end
#		    (@story.context.count < 100000).should be(true)
#		    @story.context.thread.join
#		    @story.context.count.should be(100000)		    
#		    @story.context.timesInvoked.should be(1)
#		    @story.shutdown
		end

        it "should be created by the main context" do
            @story.setup(JLDrill)
            @story.start
            @story.mainContext.loadReferenceContext.should_not be_nil
            @story.shutdown
        end
        
        it "should have a hard coded filename" do
            @story.setup(JLDrill)
            @story.start
            @story.context.filename.should_not be_nil
            File.exists?(@story.context.filename).should be(true)
            @story.shutdown
        end
        
        it "should load the parents reference dictionary on entry" do
            @story.setup(JLDrill)
            @story.start
            @story.context.reference.should be(nil)
            @story.mainContext.reference.should_not be(nil)
            @story.mainContext.reference.should_receive(:read)
            @story.context.enter(@story.mainContext)
            @story.context.timesInvoked.should be(1)
            @story.context.reference.should be(@story.mainContext.reference)
            @story.context.reference.file.should be(@story.context.filename)
            @story.shutdown
        end
        
        it "should automatically exit the context after the loading is finished" do
            @story.setup(JLDrill)
            @story.start
            @story.mainContext.reference.should_receive(:read)
            @story.context.should_receive(:exit)
            @story.context.enter(@story.mainContext)
            @story.context.timesInvoked.should be(1)
            @story.shutdown
        end

        it "should update the view when reading" do
            @story.setup(JLDrill)
            @story.start
            # I'm not totally satisfied with this test, but it's the only
            # way I could think to do it.
            reference = @story.mainContext.reference
            def reference.read(&block)
                block.call(10)
            end
            @story.context.peekAtView.should_receive(:update)
            @story.context.enter(@story.mainContext)            
            @story.shutdown
        end
        
	end
end
