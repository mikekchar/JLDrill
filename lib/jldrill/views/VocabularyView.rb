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
		
		def close
		    @context.exit
		end

        def addVocabulary
            if @vocabulary.valid?
                @context.addVocabulary(@vocabulary)
            end
        end
	end
end
