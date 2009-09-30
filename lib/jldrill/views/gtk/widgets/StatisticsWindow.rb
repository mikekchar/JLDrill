require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
        
    class StatisticsTable < Gtk::Table
        attr_reader :values
        
        def initialize(rows, columns)
            super(rows.size + 1, columns.size + 1, false)
            @values = addEntries(rows, columns)
        end
        
        def addEntries(rows, columns)
            values = makeValues(rows.size, columns.size)
            columns.each_index do |i|
                column(i + 1, columns[i])
            end
            rows.each_index do |i|
                row(i + 1, rows[i])
                0.upto(columns.size - 1) do |j|
                    addValue(values[i][j], i + 1, j + 1)
                end
            end
            values
        end
        
        def makeValues(height, width)
            retVal = []
            0.upto(height - 1) do
                retVal.push([])
            end
            0.upto(height - 1) do |i|
                0.upto(width - 1) do |j|
                    retVal[i][j] = Gtk::Label.new("0")
                end
            end
            retVal
        end
        
        def row(rowNum, text)
            label = Gtk::Label.new(text)
            # Add 1 to row to make up for the headers
            attach(label,
                   # X direction            # Y direction
                   0, 1,                    rowNum + 1, rowNum + 2,
                   Gtk::EXPAND | Gtk::FILL, 0,
                   0,                       0)
        end

        def column(colNum, text)
            label = Gtk::Label.new(text)
            # Add 1 to row to make up for the headers
            attach(label,
                   # X direction            # Y direction
                   colNum + 1, colNum + 2,  0, 1,
                   Gtk::EXPAND | Gtk::FILL, 0,
                   0,                       0)
                   
        end
        
        def addValue(value, row, column)
            # Add 1 to row to make up for the headers
            attach(value,
                   # X direction            # Y direction
                   column + 1, column + 2,      row + 1, row + 2,
                   Gtk::EXPAND | Gtk::FILL, 0,
                   0,                       0)
        end
    end
    
    class StatisticsWindow < Gtk::Window
        include Context::Gtk::Widget

        attr_reader :accel
        
        def initialize(view)
            @view = view
            @closed = false
            super("Statistics")
            connectSignals unless @view.nil?
            
            hbox = Gtk::HBox.new()
            add(hbox)
            ## Layout everything in a vertical table
            rows = [" Less than 5 days ", "5 - 10 days", "10 - 20 days", 
                      "20 - 40 days", "40 - 80 days", "80 - 160 days", 
                      "160 - 320 days", "320+ days"]
            columns = [" Scheduled ", " Duration ", 
                       " Correct ", " Tried ",]
            @scheduleTable = StatisticsTable.new(rows, columns)
            hbox.add(@scheduleTable)
            rows = ["Reviewed", "Learned", " Time to review ", 
                      "Time to learn", "Total Accuracy", " Learn Time % ", 
                      " Skew ", " Review Rate "]
            columns = [" "]
            @rateTable = StatisticsTable.new(rows, columns)
            hbox.add(@rateTable)
        end  
        
        def connectSignals
            @accel = Gtk::AccelGroup.new
            @accel.connect(Gdk::Keyval::GDK_Escape, 0,
                           Gtk::ACCEL_VISIBLE) do
                self.close
            end
            add_accel_group(@accel)
            
            signal_connect('delete_event') do
                # Request that the destroy signal be sent
                false
            end
            
            signal_connect('destroy') do
                self.close
            end
        end
        
        def close
            if !@closed
                @view.close
            end
        end
        
        def explicitDestroy
            @closed = true
            self.destroy
        end
        
        def updateSchedule(stats)
            total = 0
            0.upto(6) do |i|
                num = stats.numScheduledForLevel(i)
                rate = (stats.itemsPerDay(num, i) * 100).to_i / 100.0
                @scheduleTable.values[i][0].text = rate.to_s + "/day "
                total += num
            end
            @scheduleTable.values[7][0].text = (stats.size - total).to_s
        end
        
        def updateDuration(stats)
            total = 0
            0.upto(6) do |i|
                num = stats.numDurationForLevel(i)
                @scheduleTable.values[i][1].text = num.to_s
                total += num
            end
            @scheduleTable.values[7][1].text = (stats.size - total).to_s
        end
        
        def updateAccuracy(stats)
            0.upto(7) do |i|
                acc = stats.levels[i].accuracy
                if !acc.nil?
                    @scheduleTable.values[i][2].text = acc.to_s + "% "
                    @scheduleTable.values[i][3].text = stats.levels[i].total.to_s
                else
                    @scheduleTable.values[i][2].text = " - "
                    @scheduleTable.values[i][3].text = " - "
                end
            end
        end
        
        def updateRate(stats)
            @rateTable.values[0][0].text = stats.reviewed.to_s 
            @rateTable.values[1][0].text = stats.learned.to_s
            @rateTable.values[2][0].text = stats.reviewPace.to_s + "s "
            @rateTable.values[3][0].text = stats.learnPace.to_s + "s "
            @rateTable.values[4][0].text = stats.accuracy.to_s + "% "
            @rateTable.values[5][0].text = stats.learnTimePercent.to_s + "% "
            @rateTable.values[6][0].text = stats.dateSkew.to_s + " days"
            @rateTable.values[7][0].text = stats.reviewRate.to_s + "x "
        end
    end
end
