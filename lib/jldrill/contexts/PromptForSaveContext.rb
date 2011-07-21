# encoding: utf-8
require 'jldrill/contexts/PromptContext'

module JLDrill

	class PromptForSaveContext < JLDrill::PromptContext
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
		    @title = "Unsaved Changes"
		    @message = "You have unsaved changes\nDo you want to save?"
            super
        end
    end
end
