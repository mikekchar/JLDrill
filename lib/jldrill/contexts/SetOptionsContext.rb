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
