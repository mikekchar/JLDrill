require 'Context/Gtk/Widget'
require 'jldrill/views/StatisticsView'
require 'gtk2'
require 'jldrill/model/Quiz/Quiz'

module JLDrill::Gtk

	class StatisticsView < JLDrill::StatisticsView
	
		class StatisticsWindow < Gtk::Window
		
		    def initialize(view)
		        @view = view
		        super("Statistics")
   				connectSignals unless @view.nil?

                vbox = Gtk::VBox.new()
                add(vbox)
                ## Layout everything in a vertical table
                @table = Gtk::Table.new(2, 8, false)
                vbox.add(@table)
                labels = ["Overdue", "Today", "  Tomorrow  ", "2 Days",
                            "3 Days", "4 Days", "5 Days", "6 Days"]
                @values = addEntries(@table, labels)
		    end  
		          
		    def addEntries(table, entries)
		        values = makeValues(entries.size)
		        entries.each_index do |i|
		            addLabel(table, entries[i], i)
		            addValue(table, values[i], i)
		        end
		        values
		    end

		    def makeValues(num)
		        retVal = []
		        0.upto(num) do
		            retVal.push(Gtk::Label.new("0"))
		        end
		        retVal
		    end
		    
		    def addLabel(table, text, row)
                label = Gtk::Label.new(text)
                table.attach(label,
                             # X direction            # Y direction
                             0, 1,                    row, row + 1,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)
		    end
		    
		    def addValue(table, value, row)
                table.attach(value,
                             # X direction            # Y direction
                             1, 2,                    row, row + 1,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)
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

            def updateSchedule(bin)
                @values[0].text = bin.numOverdue.to_s
                0.upto(5) do |i|
                    @values[i+1].text = bin.numScheduledOn(i).to_s
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
		
		def update(quiz)
		    super(quiz)
		    @statisticsWindow.updateSchedule(quiz.contents.bins[4])
		end

    end   
end

