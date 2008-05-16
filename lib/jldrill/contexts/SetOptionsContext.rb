require 'Context/Context'
require 'Context/ViewFactory'
require 'jldrill/views/OptionsView'

module JLDrill

	class SetOptionsContext < Context::Context
		
	    attr_reader :filename, :quiz
		
		def initialize(viewFactory)
			super(viewFactory)
			@quiz = nil
		end
		
		def createViews
    		@mainView = @viewFactory.OptionsView.new(self)
        end
        
        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
			if (!parent.nil?) && (parent.class.public_method_defined?(:quiz))
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
