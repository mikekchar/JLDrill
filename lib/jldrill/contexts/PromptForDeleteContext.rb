require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/PromptView'

module JLDrill

	class PromptForDeleteContext < Context::Context
		
	    attr_reader :cancel, :yes, :no, :response
	    		
		def initialize(viewBridge)
			super(viewBridge)
	        @cancel = "cancel"
	        @yes = "yes"
	        @no = "no"
			@response = @cancel
		end
		
		def createViews
		    @title = "Delete?"
		    @message = "Deleting an item can not be undone\nDo you really want to delete this item?"
    		@mainView = @viewBridge.PromptView.new(self, @title, @message)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
    		@response = @mainView.run
    		self.exit
    		@response
		end
    end
end
