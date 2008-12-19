require 'jldrill/spec/StoryMemento'
require 'gtk2'

# This story tests loading the reference dictionary.
# Unfortunately, I can't test it under GTK because in order
# for the idle loop to work GTK has to be started.
module JLDrill::UserLoadsDictionary

    Story = JLDrill::StoryMemento.new("User Loads Dictionary")
    def Story.setup(type)
        super(type)
        @context = @mainContext.loadReferenceContext
        @view = @context.peekAtView
    end

    describe Story.stepName("There is a context for loading the dictionary") do
        before(:each) do
            Story.setup(JLDrill::Gtk)
        end
        
        after(:each) do
            Story.shutdown
        end

        # I suppose this test is a bit worrisome.  If the test
        # fails then, in all probability the context won't
        # exit, and the test will hang.  
        it "should load the reference dictionary" do
            Story.start
            Story.context.should_not be_nil
            Story.context.filename.should_not be_nil
            context = Story.context
            def context.exit
                super
                ::Gtk::main_quit
            end
            Story.startGtk do
                Story.view.should_receive(:update).at_least(1000).times
                Story.mainContext.loadReference
            end
        end
    end
end
