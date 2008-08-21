require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/PromptView'

module JLDrill

	class PromptForSaveContext < Context::Context
		
	    attr_reader :cancel, :yes, :no, :response
	    		
		def initialize(viewBridge)
			super(viewBridge)
	        @cancel = "cancel"
	        @yes = "yes"
	        @no = "no"
			@response = @cancel
		end
		
		def createViews
		    @title = "Unsaved Changes"
		    @message = "You have unsaved changes\nDo you want to save?"
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
    		if @response == @yes
    		    @parent.save
    		end
    		@response
		end
    end
end
