# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/model/quiz/Counter'
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
   
    class StatisticsPage

        attr_reader :widget, :durationTable, :rateTable

        def initialize(view)
            @view = view
            @widget = Gtk::HBox.new()
            
            ## Layout everything in a vertical table
            counter = JLDrill::Counter.new
            rows = []
            0.upto(7) do |i|
                rows = rows.push(counter.levelString(i))
            end
            columns = [" Duration ", " Correct ", " Tried ",]
            @durationTable = StatisticsTable.new(rows, columns)
            @widget.add(@durationTable)
            rows = ["Reviewed", "Learned", " Time to review ", 
                      "Time to learn", "Total Accuracy", " Learn Time % ", 
                      " Curr Rate ", " Avg Rate "]
            columns = [" "]
            @rateTable = StatisticsTable.new(rows, columns)
            @widget.add(@rateTable)
        end

        def updateDuration(counter)
            table = counter.table
            0.upto(6) do |i|
                @durationTable.values[i][0].text = table[i].to_s
            end
            @durationTable.values[7][0].text = table[7].to_s
        end
        
        def updateAccuracy(stats)
            0.upto(7) do |i|
                acc = stats.levels[i].accuracy
                if !acc.nil?
                    @durationTable.values[i][1].text = acc.to_s + "% "
                    @durationTable.values[i][2].text = stats.levels[i].total.to_s
                else
                    @durationTable.values[i][1].text = " - "
                    @durationTable.values[i][2].text = " - "
                end
            end
        end
        
        def updateReviewRate(contentStats)
            @rateTable.values[0][0].text = contentStats.reviewSetItemsViewed.to_s 
            @rateTable.values[1][0].text = contentStats.workingSetItemsLearned.to_s
            @rateTable.values[2][0].text = contentStats.reviewSetReviewPace.to_s + "s "
            @rateTable.values[3][0].text = contentStats.workingSetLearnedPace.to_s + "s "
            @rateTable.values[4][0].text = contentStats.reviewAccuracy.to_s + "% "
            @rateTable.values[5][0].text = contentStats.learnTimePercent.to_s + "% "
            @rateTable.values[6][0].text = contentStats.reviewSetRate.to_s + "x "
            @rateTable.values[7][0].text = contentStats.averageReviewSetRate.to_s + "x "
        end
        
        def updateForgottenRate(contentStats)
            @rateTable.values[0][0].text = contentStats.forgottenSetItemsViewed.to_s 
            @rateTable.values[1][0].text = contentStats.workingSetItemsLearned.to_s
            @rateTable.values[2][0].text = contentStats.forgottenSetReviewPace.to_s + "s "
            @rateTable.values[3][0].text = contentStats.workingSetLearnedPace.to_s + "s "
            @rateTable.values[4][0].text = contentStats.forgottenAccuracy.to_s + "% "
            @rateTable.values[5][0].text = contentStats.learnTimePercent.to_s + "% "
            @rateTable.values[6][0].text = contentStats.forgottenSetRate.to_s + "x "
            @rateTable.values[7][0].text = contentStats.averageForgottenSetRate.to_s + "x "
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

            tabs = Gtk::Notebook.new()
            add(tabs)
            reviewSetLabel = Gtk::Label.new("Review Set")
            @reviewStats = StatisticsPage.new(view)
            tabs.append_page(@reviewStats.widget, reviewSetLabel)
            forgottenSetLabel = Gtk::Label.new("Forgotten Set")
            @forgottenStats = StatisticsPage.new(view)
            tabs.append_page(@forgottenStats.widget, forgottenSetLabel)
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

        def updateReviewDuration(counter)
            @reviewStats.updateDuration(counter)
        end

        def updateReviewAccuracy(stats)
            @reviewStats.updateAccuracy(stats)
        end

        def updateReviewRate(stats)
            @reviewStats.updateReviewRate(stats)
        end
        
        def updateForgottenDuration(counter)
            @forgottenStats.updateDuration(counter)
        end

        def updateForgottenAccuracy(stats)
            @forgottenStats.updateAccuracy(stats)
        end

        def updateForgottenRate(stats)
            @forgottenStats.updateForgottenRate(stats)
        end
        
        def showBusy(bool)
            if bool
                self.window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::WATCH))
            else
                self.window.set_cursor(nil)
            end
            Gdk::flush()
        end
    end
end
