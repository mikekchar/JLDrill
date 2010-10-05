require 'jldrill/contexts/MainContext.rb'

module JLDrill::Test
    class MainWindowView < JLDrill::MainContext::MainWindowView

        attr_reader :destroyed
        attr_writer :destroyed

        def initialize(context)
            super(context)
            @destroyed = false
        end

        def destroy
            @destroyed = true
        end
    end
end
