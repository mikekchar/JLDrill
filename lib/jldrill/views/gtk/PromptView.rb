require 'Context/Gtk/Widget'
require 'jldrill/views/PromptView'
require 'gtk2'

module JLDrill::Gtk

	class PromptView < JLDrill::PromptView

        class PromptWindow < Gtk::Dialog

	        attr_reader :response

	        def initialize(view, title, message)
	            @view = view
	            @response = @view.context.cancel
		        super(title, nil,
                        Gtk::Dialog::DESTROY_WITH_PARENT,
                        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                        [Gtk::Stock::NO, Gtk::Dialog::RESPONSE_NO],
                        [Gtk::Stock::YES, Gtk::Dialog::RESPONSE_YES])
                self.vbox.add(Gtk::Label.new(message))
	        end
	        	
	        def execute
	            self.run do |response|
                    case response
                        when Gtk::Dialog::RESPONSE_YES
                            @response = @view.context.yes
                        when Gtk::Dialog::RESPONSE_NO 
                            @response = @view.context.no
                    else 
                        @response = @view.context.cancel
                    end
                end
                @response
	        end

        end	    
        attr_reader :selectorWindow
        	
		def initialize(context, title, message)
			super(context, title, message)
			@promptWindow = PromptWindow.new(self, title, message)
			@widget = Context::Gtk::Widget.new(@promptWindow)
		end
		
		def getWidget
			@widget
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

