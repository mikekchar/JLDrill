# encoding: utf-8
#require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/spec/StoryMemento'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

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
            Story.setup(JLDrill::Test)
            Story.start
            Story.shutdown
        end
        
#        it "Selecting the entry in the menu should enter the context"
    end

###########################################

end
