# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class PromptContext < Context::Context
		
	    attr_reader :cancel, :yes, :no, :response, :title, :message
	    		
		def initialize(viewBridge)
			super(viewBridge)
	        @cancel = "cancel"
	        @yes = "yes"
	        @no = "no"
			@response = @cancel
            @title = "Prompt"
            @message = "Please replace this with a question for the user."
		end
	
        class PromptView < Context::View
            attr_reader  :response, :title, :message

            def initialize(context, title, message)
                super(context)
                @title = title
                @message = message
                @response = @context.cancel
            end

            # Destroys the prompt window
            def destroy
                # Please override in the concrete class
            end

            # Display the dialog and get the input from the user
            def run
                # Please override in the concrete class
            end
        end

        # The concrete class should override this method    
		def createViews
            # Please set the title and message member variables
            # and call super() in the concrete class
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
    		return @response
		end
    end
end
