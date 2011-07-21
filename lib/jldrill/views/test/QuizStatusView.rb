# encoding: utf-8
require 'jldrill/contexts/DisplayQuizStatusContext'

module JLDrill::Test

	class QuizStatusView < JLDrill::DisplayQuizStatusContext::QuizStatusView
	
        attr_reader :updated
        attr_writer :updated
        	
		def initialize(context)
			super(context)
            @updated = false
		end
		
		def update(quiz)
		    @updated = true
		end
    end    
end
