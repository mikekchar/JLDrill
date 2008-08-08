require 'Context/Gtk/Widget'
require 'jldrill/views/StatisticsView'
require 'gtk2'
require 'jldrill/model/Quiz/Quiz'

module JLDrill::Gtk

	class StatisticsView < JLDrill::StatisticsView
	
	    class StatisticsTable < Gtk::Table
	        attr_reader :values

	        def initialize(entries, width=1)
	            super(width, entries.size, false)
	            @columns = width
	            @values = addEntries(entries)
	        end

		    def addEntries(entries)
		        values = makeValues(entries.size)
		        entries.each_index do |i|
		            addLabel(entries[i], i)
		            if @columns > 1
		                0.upto(@columns - 1) do |j|
		                    addValue(values[j][i], i, j+1)
		                end
		            else
    		            addValue(values[i], i)
    		        end
		        end
		        values
		    end

		    def makeValues(num)
   		        retVal = []
		        if @columns > 1
    		        0.upto(@columns - 1) do
    		            retVal.push([])
    		        end
    		    end
		        0.upto(num) do |i|
		            if @columns > 1
		                0.upto(@columns - 1) do |j|
		                    retVal[j].push(Gtk::Label.new("0"))
		                end
		            else
    		            retVal.push(Gtk::Label.new("0"))
    		        end
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
		    
		    def addValue(value, row, column=1)
                attach(value,
                       # X direction            # Y direction
                       column, column + 1,                    row, row + 1,
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
                labels = [" Level 1 ", " Level 2 ", " Level 3 ", " Level 4 ",
                            " Level 5 ", " Level 6 ", " Level 7 ", " Level 8 "]
                @accuracyTable = StatisticsTable.new(labels, 2)
                hbox.add(@accuracyTable)
                labels = ["Reviewed", "Learned", " Time to review ", 
                            "Time to learn", "Total Accuracy", " Learn Time % ", 
                            " ", " "]
                @rateTable = StatisticsTable.new(labels)
                hbox.add(@rateTable)
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
            
            def updateAccuracy(statistics)
                0.upto(7) do |i|
                    acc = statistics.levels[i].accuracy
                    if !acc.nil?
                        @accuracyTable.values[0][i].text = acc.to_s + "% "
                        @accuracyTable.values[1][i].text = statistics.levels[i].total.to_s
                    else
                        @accuracyTable.values[0][i].text = " - "
                        @accuracyTable.values[1][i].text = " - "
                    end
                end
            end
            
            def updateRate(statistics)
                @rateTable.values[0].text = statistics.reviewed.to_s 
                @rateTable.values[1].text = statistics.learned.to_s
                @rateTable.values[2].text = statistics.reviewPace.to_s + "s "
                @rateTable.values[3].text = statistics.learnPace.to_s + "s "
                @rateTable.values[4].text = statistics.accuracy.to_s + "% "
                @rateTable.values[5].text = statistics.learnTimePercent.to_s + "% "
                @rateTable.values[6].text = "    "
                @rateTable.values[7].text = "    "
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
		    @statisticsWindow.updateAccuracy(quiz.strategy.stats)
		    @statisticsWindow.updateRate(quiz.strategy.stats)
		end

    end   
end

