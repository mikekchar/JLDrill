require 'Context/View'

module JLDrill
	class VocabularyTableView < Context::View
	    attr_reader :quiz
	
		def initialize(context)
			super(context)
			@quiz = nil
		end
		
		def destroy
		    # Only in the concrete class
		end
		
		def update(items)
            # Only in the concrete class
		end

        def close
            @context.exit
        end
	end
end
