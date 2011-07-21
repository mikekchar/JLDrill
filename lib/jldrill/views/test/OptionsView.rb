# encoding: utf-8
require 'jldrill/contexts/SetOptionsContext'

module JLDrill::Test
	class OptionsView < JLDrill::SetOptionsContext::OptionsView
	    attr_reader :destroyed, :updated, :filename, :hasRun
	    attr_writer :destroyed, :updated, :filename, :hasRun
	
		def initialize(context)
			super(context)
            @destroyed = false
            @updated = false
            @filename = nil
            @hasRun = false
		end

        def destroy
            @destroyed = true
        end

		def update(options)
		    @updated = true
		end

        def setDictionaryFilename(filename)
            @filename = filename
        end
		
		def run
            @hasRun = true
            super
		end
	end
end
