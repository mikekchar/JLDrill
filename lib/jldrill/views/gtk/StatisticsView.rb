require 'Context/Gtk/Widget'
require 'jldrill/views/StatisticsView'
require 'gtk2'
require 'jldrill/model/Quiz/Quiz'

module JLDrill::Gtk

	class StatisticsView < JLDrill::StatisticsView
	
	    class StatisticsTable < Gtk::Table
	        attr_reader :values
	        
	        def initialize(entries)
	            super(2, entries.size, false)
	            @values = addEntries(entries)
	        end
	    
		    def addEntries(entries)
		        values = makeValues(entries.size)
		        entries.each_index do |i|
		            addLabel(entries[i], i)
		            addValue(values[i], i)
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
		    
		    def addLabel(text, row)
                label = Gtk::Label.new(text)
                attach(label,
                       # X direction            # Y direction
                       0, 1,                    row, row + 1,
                       Gtk::EXPAND | Gtk::FILL, 0,
                       0,                       0)
		    end
		    
		    def addValue(value, row)
                attach(value,
                       # X direction            # Y direction
                       1, 2,                    row, row + 1,
                       Gtk::EXPAND | Gtk::FILL, 0,
                       0,                       0)
		    end
	    end
	
		class StatisticsWindow < Gtk::Window
		
		    def initialize(view)
		        @view = view
		        super("Statistics")
   				connectSignals unless @view.nil?

                hbox = Gtk::HBox.new()
                add(hbox)
                ## Layout everything in a vertical table
                labels = ["Overdue", "Today", "  Tomorrow  ", "2 Days",
                            "3 Days", "4 Days", "5 Days", "6 Days"]
                @scheduleTable = StatisticsTable.new(labels)
                hbox.add(@scheduleTable)
                labels = [" Less than 5 days ", "5 - 10 days", "10 - 20 days", 
                            "20 - 40 days", "40 - 80 days", "80 - 160 days", 
                            "160 - 320 days", "320+ days"]
                @durationTable = StatisticsTable.new(labels)
                hbox.add(@durationTable)
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
                @scheduleTable.values[0].text = bin.numOverdue.to_s
                0.upto(6) do |i|
                    @scheduleTable.values[i+1].text = bin.numScheduledOn(i).to_s
                end
            end
            
            def findRange(level)
                low = 0
                high = 5
                1.upto(level) do
                    if low == 0
                        low = 5
                    else
                        low = low * 2
                    end
                    high = low * 2
                end
                low..high
            end
            
            def updateDuration(bin)
                total = 0
                0.upto(6) do |i|
                    num = bin.numDurationWithin(findRange(i))
                    @durationTable.values[i].text = num.to_s
                    total += num
                end
                @durationTable.values[7].text = (bin.length - total).to_s
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
		    @statisticsWindow.updateDuration(quiz.contents.bins[4])
		end

    end   
end

