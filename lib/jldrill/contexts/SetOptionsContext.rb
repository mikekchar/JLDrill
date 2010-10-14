require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/OptionsView'
require 'jldrill/contexts/GetFilenameContext'

module JLDrill

	class SetOptionsContext < Context::Context
		
	    attr_reader :filename, :quiz
		
		def initialize(viewBridge)
			super(viewBridge)
			@quiz = nil
		end
		
        class OptionsView < Context::View
            attr_reader :options

            def initialize(context)
                super(context)
                @optionsSet = false
                @options = Options.new(nil)
            end

            # Destroy the options window
            def destroy
                # Please define in the concrete class
            end

            # Indicate that the options have been modified or not.
            def optionsSet=(bool)
                @optionsSet = bool
            end

            # Returns true if the options have been modified
            def optionsSet?
                return @optionsSet
            end

            # Update the UI with the options passed in
            def update(options)
                @options.assign(options)
                # Call super() first and then write UI specific code
            end

            # Update the UI with the filename of the dictionary
            def setDictionaryFilename(filename)
                # Please override in the concrete class
            end

            # Display the options dialog and get input from the user
            def run
                # Please write the code for the concrete class and then
                # call super().  This will simply exit the context.
                exit
            end

            # This is a convenience method for the tests so that they
            # have something to catch rather than the exit() on the context.
            def exit
                @context.exit
            end
        end

        def createViews
    		@mainView = @viewBridge.OptionsView.new(self)
        end

        def destroyViews
            @mainView.destroy
            @mainView = nil
        end		    
		
		def hasQuiz?(parent)
		    !parent.nil? && parent.class.public_method_defined?(:quiz) &&
		        !parent.quiz.nil?
		end

        def getDictionaryFilename
            context = GetFilenameContext.new(@viewBridge, GetFilenameContext::OPEN)
            filename = context.enter(self)
            if !filename.nil?
                @mainView.setDictionaryFilename(filename)
            end
        end
		
		def enter(parent)
			if hasQuiz?(parent)
       			super(parent)
    			@quiz = parent.quiz
    			@mainView.update(@quiz.options)
    			@mainView.run
            end
		end
		
		def exit
		    if @mainView.optionsSet?
		        @quiz.options.assign(@mainView.options)
		    end
		    super
		end
    end
end
