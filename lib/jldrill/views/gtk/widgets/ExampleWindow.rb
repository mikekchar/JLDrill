# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/views/gtk/widgets/KanjiPopupFactory'
require 'jldrill/views/gtk/widgets/VocabPopupFactory'
require 'gtk2'

module JLDrill::Gtk
    class ExampleWindow < Gtk::Window
        include Context::Gtk::Widget

        def initialize(view)
            @view = view
            @context = @view.context
			@closed = false
            super("Examples")
            @accel = Gtk::AccelGroup.new
            @kanjiPopupFactory = KanjiPopupFactory.new(view)
            @vocabPopupFactory = VocabPopupFactory.new(view)
            @popupFactory = @kanjiPopupFactory
            @lastEvent = nil

            sw = Gtk::ScrolledWindow.new
            sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            sw.shadow_type = Gtk::SHADOW_IN
            self.add(sw)
            
            @contents = Gtk::TextView.new
            @contents.wrap_mode = Gtk::TextTag::WRAP_WORD
            @contents.editable = false
            @contents.cursor_visible = false
            sw.add(@contents)
            self.set_default_size(400, 360)
			connectSignals unless @view.nil?
            createTags
        end

        def createTags
            @contents.buffer.create_tag("normal", 
                               "size" => 12 * Pango::SCALE,
                               "background" => "#ffffff")
            @contents.buffer.create_tag("checked", 
                               "size" => 12 * Pango::SCALE,
                               "background" => "#e0f0ff")
            @contents.buffer.create_tag("h1",
                                        "size" => 20 * Pango::SCALE,
                                        "justification" => Gtk::JUSTIFY_CENTER)
            @contents.buffer.create_tag("h2",
                                        "size" => 15 * Pango::SCALE,
                                        "justification" => Gtk::JUSTIFY_CENTER)

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

            # Kanji Popup
            @contents.add_events(Gdk::Event::POINTER_MOTION_MASK)
            @contents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
            
            @contents.signal_connect('motion_notify_event') do |widget, motion|
                @lastEvent = MotionEvent.new(widget, motion)
                @popupFactory.notify(@lastEvent)
            end

            @contents.signal_connect('leave_notify_event') do
                @popupFactory.closePopup
            end
            
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

        def sortExamples(examples)
           return examples.sort do |x, y|
               retVal = x.key.sense <=> y.key.sense
               if y.key.checked && !x.key.checked
                   retVal = 1
               end
               if x.key.checked && !y.key.checked
                   retVal = -1
               end
               retVal
           end
        end

        def insertHeader(section, example)
            if example.key.checked
                if section == -2
                    section = -1
                    insert("Checked Examples\n", "h1")
                    insertVSpace
                end
            else
                if section < 0
                    insert("Unchecked Examples\n", "h1")
                    insertVSpace
                end
                if section != example.key.sense
                    section = example.key.sense
                    if section != 0
                        insertVSpace
                        insert("Examples for sense ##{section}\n", "h2")
                    end
                end
            end
            return section
        end

        def getTag(example)
            if (example.key.checked) 
                tag = "checked"
            else
                tag = "normal"
            end
        end

        def updateNativeOnly(examples)
            @contents.buffer.text = ""
            if !examples.nil?
                section = -2
                sortExamples(examples).each do |example|
                    section = insertHeader(section, example)
                    insert(example.nativeOnly_to_s + "\n", getTag(example))
                    insertVSpace
                end
            end
        end

        def updateTargetOnly(examples)
            @contents.buffer.text = ""
            if !examples.nil?
                section = -2
                sortExamples(examples).each do |example|
                    section = insertHeader(section, example)
                    insert(example.targetOnly_to_s + "\n", getTag(example))
                    insertVSpace
                end
            end
        end

        def updateContents(examples)
            @contents.buffer.text = ""
            if !examples.nil?
                section = -2
                sortExamples(examples).each do |example|
                    section = insertHeader(section, example)
                    insert(example.to_s + "\n", getTag(example))
                    insertVSpace
                end
            end
        end

        def insert(text, tag)
            @contents.buffer.insert(@contents.buffer.end_iter, text, tag)
        end

        def insertVSpace
            insert("\n", "normal")
        end

        def showBusy(bool)
            # TextViews have a hidden subwindow that houses the cursor
            subwindow = @contents.get_window(Gtk::TextView::WINDOW_TEXT)
            if bool
                subwindow.set_cursor(Gdk::Cursor.new(Gdk::Cursor::WATCH))
            else
                subwindow.set_cursor(nil)
            end
            Gdk::flush()
        end
    end
end
