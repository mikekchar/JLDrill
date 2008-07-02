require 'Context/Gtk/Widget'
require 'jldrill/views/StatisticsView'
require 'gtk2'

module JLDrill::Gtk

	class StatisticsView < JLDrill::StatisticsView
	
		class StatisticsWindow < Gtk::Window
		
		    def initialize(view)
		        @view = view
		        super("Statistics")
   				connectSignals unless @view.nil?

                vbox = Gtk::VBox.new()
                add(vbox)
		    end
		    
		    def connectSignals
			    signal_connect('delete_event') do
                    # Request that the destroy signal be sent
                    false
                end

				signal_connect('destroy') do
					@view.close
				end
			end

        end
    
        attr_reader :statisticsWindow
        	
		def initialize(context)
			super(context)
			@statisticsWindow = StatisticsWindow.new(self)
			@widget = Context::Gtk::Widget.new(@statisticsWindow)
		end
		
		def getWidget
			@widget
		end
		
		def emitDestroyEvent
			@statisticsWindow.signal_emit("destroy")
		end

    end   
end

