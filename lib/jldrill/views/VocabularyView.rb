require 'Context/View'
require 'jldrill/model/Vocabulary'

module JLDrill
	class VocabularyView < Context::View
	    attr_reader :vocabulary
	
		def initialize(context)
			super(context)
			@vocabulary = Vocabulary.new
		end

		def run
		    super
		end
		
		def exit
		    super
		end

	end
end
