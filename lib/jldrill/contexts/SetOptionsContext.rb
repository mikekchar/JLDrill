require 'Context/Context'
require 'Context/ViewFactory'
require 'jldrill/views/OptionsView'

module JLDrill

	class SetOptionsContext < Context::Context
		
	    attr_reader :filename, :quiz
		
		def initialize(viewFactory)
			super(viewFactory)
			@mainView = viewFactory.OptionsView.new(self)
			@quiz = nil
		end
		
		def enter(parent)
			if (!parent.nil?) && (parent.class.public_method_defined?(:quiz))
    			@quiz = parent.quiz
    			@mainView.update(@quiz.options)
       			super(parent)
            end
		end
		
		def exit
		    @mainView.close
		    options.assign(@mainView.options)
		    super(exit)
		end
    end
end
