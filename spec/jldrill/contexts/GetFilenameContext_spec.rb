require 'jldrill/contexts/GetFilenameContext'
require 'Context/Bridge'
require 'jldrill/views/FilenameSelectorView'

module JLDrill

	describe GetFilenameContext do

		before(:each) do
			@main = MainContext.new(Context::Bridge.new(JLDrill))
            @main.inTests = true
			@main.createViews
			@context = @main.getFilenameContext
			@context.createViews
			@view = @context.mainView
			
    		def @context.createViews
	    	    # Use the previously set View
    		end

		end
		
        it "should be created by the main context" do
            @main.getFilenameContext.should_not be_nil
        end
        
        it "should immediately exit the context after entering it" do
            @context.should_receive(:exit)
            filename = @context.enter(@main)
        end
        
        it "should set the filename and directory from the view" do
            @view.filename = "filename"
            # The context set's the view's directory, but we want to
            # show that when the view's directory is changed it gets
            # updated in the context.  So we rewrite the view's directory
            # method.
            def @view.directory
                "directory"
            end
            filename = @context.enter(@main)
            filename.should be_eql("filename")
            @context.filename.should be_eql("filename")
            @context.directory.should be_eql("directory")
        end
        
	end
end
