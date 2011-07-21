# encoding: utf-8
require 'jldrill/contexts/RunCommandContext'

module JLDrill::Test

    class CommandView < JLDrill::RunCommandContext::CommandView

        attr_reader :updated

        def initialize(context)
            super(context)
            @updated = false
        end

        def update
            @updated = true
        end
    end
end

