require 'jldrill/views/gtk/widgets/PromptWindow'
require 'jldrill/views/PromptView'
require 'gtk2'

module JLDrill::Gtk

	class PromptView < JLDrill::PromptView
        attr_reader :selectorWindow
        	
		def initialize(context, title, message)
			super(context, title, message)
			@promptWindow = PromptWindow.new(self, title, message)
		end
		
		def getWidget
			@promptWindow
		end

        def destroy
            @promptWindow.destroy
        end

        def run
            @response = @promptWindow.execute
            @response
        end
    end
end
