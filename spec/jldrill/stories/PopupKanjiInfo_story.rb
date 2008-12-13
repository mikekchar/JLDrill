#require 'jldrill/contexts/DisplayProblemContext'
#require 'jldrill/views/ProblemView'
#require 'jldrill/views/gtk/ProblemView'
require 'jldrill/spec/StoryMemento'

module JLDrill::PopupKanjiInfo

    Story = JLDrill::StoryMemento.new("Pop up kanji info")
    def Story.setup(type)
        super(type)
#        @context = @mainContext.displayProblemContext
#        @view = @context.peekAtView
    end

###########################################

    describe Story.stepName("The user is able to select popup kanji option") do
        it "should have an entry in the menu" do
            Story.setup(JLDrill)
            Story.start
            Story.shutdown
        end
        
#        it "Selecting the entry in the menu should enter the context"
    end

###########################################

end
