require 'jldrill/contexts/PromptContext'

module JLDrill

	class PromptForDeleteContext < JLDrill::PromptContext
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
		    @title = "Delete?"
		    @message = "Deleting an item can not be undone\nDo you really want to delete this item?"
            super()
        end
    end
end
