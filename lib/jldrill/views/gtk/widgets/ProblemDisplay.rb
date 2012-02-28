# encoding: utf-8
require 'jldrill/views/gtk/widgets/ProblemPane'
require 'Context/Views/Gtk/Widgets/VBox'
require 'jldrill/views/gtk/widgets/KanjiPopupFactory'
require 'jldrill/views/gtk/widgets/VocabPopupFactory'
require 'gtk2'

module JLDrill::Gtk
    
    # This is the widget that displays the problem.
    # The display is made up of 2 pieces:
    # the QuestionPane, which shows the question for the problem
    # and the AnswerPane which shows the answer.
    # The ProblemDisplay also interacts with the PopupFactory
    # to display the kanji/kana Popup when hovering over a character.
    class ProblemDisplay < Context::Gtk::VBox
        attr_reader :question, :answer, :accel

        def initialize(view)
            @view = view
            @context = @view.context
            super()
            @vpane = nil
            @question = QuestionPane.new(self)
            @answer = AnswerPane.new(self)
            @problem = nil
            @kanjiPopupFactory = KanjiPopupFactory.new(view)
            @vocabPopupFactory = VocabPopupFactory.new(view)
            # Default to Kanji Popups
            @popupFactory = @kanjiPopupFactory
            @lastEvent = nil
            @accel = Gtk::AccelGroup.new
            packVPane
            connectSignals
            afterWidgetIsAdded do
                gtkWidgetMainWindow.add_accel_group(@accel)
            end
        end

        def removeVPane
            if !@vpane.nil?
                @vpane.remove(@question)
                @vpane.remove(@answer)
                self.remove(@vpane)
                @vpane = nil
            end
        end

        def packVPane
            @vpane = Gtk::VPaned.new
            @vpane.set_border_width(5)
            @vpane.pack1(@question, true, true)
            @vpane.pack2(@answer, true, true)
            self.pack_end(@vpane, true, true)
            @vpane.show
        end
	        
        def connectSignals
            @question.contents.add_events(Gdk::Event::POINTER_MOTION_MASK)
            @question.contents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
            @answer.contents.add_events(Gdk::Event::POINTER_MOTION_MASK)
            @answer.contents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
            
            @accel.connect(Gdk::Keyval::GDK_space, 0, Gtk::ACCEL_VISIBLE) do
                @popupFactory.closePopup
                if @context.dictionaryLoaded?
                    if @popupFactory == @kanjiPopupFactory
                        @popupFactory = @vocabPopupFactory
                    else
                        @popupFactory = @kanjiPopupFactory
                    end
                    if !@lastEvent.nil?
                        @popupFactory.notify(@lastEvent)
                    end
                end
            end
            
            @question.contents.signal_connect('motion_notify_event') do |widget, motion|
                @lastEvent = MotionEvent.new(widget, motion)
                @popupFactory.notify(@lastEvent)
            end

            @answer.contents.signal_connect('motion_notify_event') do |widget, motion|
                @lastEvent = MotionEvent.new(widget, motion)
                @popupFactory.notify(@lastEvent)
            end
            
            @question.contents.signal_connect('leave_notify_event') do
                @popupFactory.closePopup
            end
            
            @answer.contents.signal_connect('leave_notify_event') do
                @popupFactory.closePopup
            end
        end

        def clear
            @popupFactory.closePopup
            @problem = nil
            @question.clear(nil)
            @answer.clear(nil)
            adjustSizeForQuestion
        end
        
        def newProblem(problem)
            @popupFactory.closePopup
            @problem = problem
            @answer.clear(@problem)
            @question.update(problem)
            adjustSizeForQuestion
        end

        # Attempt to adjust the size of the question pane
        # to accomodate the size of the question
        # Note: This method is in an idle_add block because
        # we have to wait until the pane has been redrawn before
        # we calculate the size.  By putting it in an idle_add
        # block we can ensure that the events that draw the pane
        # have finished.
        def adjustSizeForQuestion
            Gtk.idle_add do
                pos = @question.bufferSize
                # But don't adjust the size unnecessarily
                if pos > @vpane.position
                    @vpane.position = pos
                end
                false
            end
        end
        
        def showAnswer
            if !@problem.nil?
                @answer.update(@problem)
                adjustSizeForAnswer
            end
        end

        # Try to accomodate the answer size.  Always
        # keep 10% of the panel for the question, though.
        # Note: This method is in an idle_add block because
        # we have to wait until the pane has been redrawn before
        # we calculate the size.  By putting it in an idle_add
        # block we can ensure that the events that draw the pane
        # have finished.
        def adjustSizeForAnswer
            Gtk.idle_add do
                maxPos = @vpane.max_position
                minPos = (maxPos.to_f * 0.10).to_i
                pos = maxPos - @answer.bufferSize
                if pos < minPos
                    pos = minPos
                end
                # Don't adjust the size unnecessarily
                if pos < @vpane.position
                    @vpane.position = pos
                end
            end
        end


        def expire
            if !@problem.nil?
                @question.expire
            end
        end
        
        def showingAnswer?
            !@answer.clear?
        end
        
        def updateProblem(problem)
            needToDisplayAnswer = showingAnswer?
            newProblem(problem)
            if needToDisplayAnswer
                showAnswer
            end
        end

        def expandWithSavePath(filename)
            @context.expandWithSavePath(filename)
        end
        
        def showBusy(bool)
            if bool
                @vpane.window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::WATCH))
                self.window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::WATCH))
            else
                @vpane.window.set_cursor(nil)
                self.window.set_cursor(nil)
            end
            Gdk::flush
            @popupFactory.showBusy(bool)
            @question.showBusy(bool)
            @answer.showBusy(bool)
        end
    end
end
