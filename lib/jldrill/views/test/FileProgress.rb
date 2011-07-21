# encoding: utf-8
require 'jldrill/contexts/FileProgressContext'

module JLDrill::Test
    class FileProgress < JLDrill::FileProgressContext::FileProgress

        attr_reader :fraction, :calls
        attr_writer :fraction, :calls

        def initialize(context)
            super(context)
            @fraction = 0
            @calls = 0
        end

        def update(fraction)
            @fraction = fraction
        end

        def idle_add(&block)
            while !block.call
                @calls += 1
            end
        end
    end
end
