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
 
        def updateContents(examples)
			string = ""
			string = examples.join("\n") unless examples.nil?
            @contents.buffer.text = string
        end
    end
end
