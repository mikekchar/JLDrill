# encoding: utf-8
require 'jldrill/contexts/ShowExamplesContext'

module JLDrill::Test
	class ExampleView < JLDrill::ShowExamplesContext::ExampleView
    
        attr_reader :destroyed, :examples
        attr_writer :destroyed, :examples    

		def initialize(context)
			super(context)
            @destroyed = false
            @examples = []
		end
		
        def destroy
            @destroyed = true
        end
		
		def update(examples)
		    @examples = examples
		end
    end   
end
