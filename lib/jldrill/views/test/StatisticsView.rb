# encoding: utf-8
require 'jldrill/contexts/ShowStatisticsContext'

module JLDrill::Test
	class StatisticsView < JLDrill::ShowStatisticsContext::StatisticsView

        attr_reader :closed, :destroyed, :updated
        attr_writer :closed, :destroyed, :updated
	
		def initialize(context)
			super(context)
            @closed = false
            @destroyed = false
            @updated = true
		end
		
		def close
            @closed = true
            super
		end

		def destroy
           @destroyed = true 
        end

		def update(quiz)
		    super(quiz)
            @updated = true
		end
	end
end
