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
		
		def destroy
		    # Only for the concrete class
		end

        # Returns true if the vocabulary has been added
        def addVocabulary
            if @vocabulary.valid?
                @context.addVocabulary(@vocabulary)
                true
            else
                false
            end
        end
        
        def search(reading)
            @context.search(reading)
        end
	end
end
