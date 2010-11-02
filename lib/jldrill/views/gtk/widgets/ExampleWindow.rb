require 'Context/Gtk/Widget'
require 'jldrill/views/gtk/widgets/PopupFactory'
require 'gtk2'

module JLDrill::Gtk
    class ExampleWindow < Gtk::Window
        include Context::Gtk::Widget

        def initialize(view)
            @view = view
			@closed = false
            super("Examples") 
            @popupFactory = PopupFactory.new(view)

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
                               "background" => "#ffffff")
            @contents.buffer.create_tag("checked", 
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
                @popupFactory.notify(widget, motion.window, motion.x, motion.y)
            end

            @contents.signal_connect('leave_notify_event') do
                @popupFactory.closePopup
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
               retVal = x.sense <=> y.sense
               if y.checked && !x.checked
                   retVal = 1
               end
               if x.checked && !y.checked
                   retVal = -1
               end
               retVal
           end
        end
 
        def updateContents(examples)
            @contents.buffer.text = ""
            if !examples.nil?
                section = -2
                sortExamples(examples).each do |example|
                    if example.checked
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
                        if section != example.sense
                            section = example.sense
                            if section != 0
                                insertVSpace
                                insert("Examples for sense ##{section}\n", "h2")
                            end
                        end
                    end
                    insert(example.to_s + "\n", "normal")
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
    end
end
