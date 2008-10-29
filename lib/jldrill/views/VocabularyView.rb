require 'Context/View'
require 'jldrill/model/Vocabulary'

module JLDrill
	class VocabularyView < Context::View
	    attr_reader :vocabulary, :label, :block
	
		def initialize(context, label, &block)
			super(context)
			@vocabulary = Vocabulary.new
			@label = label
			@block = block
		end

		def run
		    # Only for the concrete class
		end
		
		def close
		    @context.exit
		end
		
		def destroy
		    # Only for the concrete class
		end

        def update(vocabulary)
            @vocabulary = vocabulary
        end

        def updateSearch
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
        
        def setVocabulary
            @context.setVocabulary(@vocabulary)
        end

        def dictionaryLoaded?
            @context.dictionaryLoaded?
        end
	end
end
