# encoding: utf-8
require 'gtk2'

module Context::Gtk

    # A Gtk widget representing a main window.
    # It is simply a Gtk::Window into which you can add new widgets.
    # You must implement the following methods on the view that
    # you pass to initialize:
    #
    #     close() -- closes the view.
    class MainWindow < Gtk::Window
        include Context::Gtk::Widget
        # Create a main window with a given title corresponding to
        # a Context::View.
        def initialize(title, view)
            super(title)
            @view = view
            setupWidget
            isAMainWindow
            @closed = false
            connectSignals unless @view.nil?
        end

        # Connect the Gtk signals we care about.
        def connectSignals
            signal_connect('destroy') do
                if !@closed
                    closeView
                end
            end
            signal_connect('delete-event') do
                if !@closed
                    closeView
                end
                true
            end
        end
        
        # Explicitly destroy the window through the code rather
        # than having the window destroyed by pressing the close
        # button.
        def explicitDestroy
            @closed = true
            self.destroy
        end
        
        # Close the view. This is called when the destroy
        # signal has been emitted.
        # Note: the View *must* implement close()
        def closeView
            @view.close
        end

        # Context::Gtk::Widget requirements

        # Add a widget to this window.  
        # Note that Gtk::Windows can only add a single item.
        # If you want to add more items, you will have to make
        # another widget (like a table or a vbox) and add it to
        # this one.
        def gtkAddWidget(widget)
            add(widget)
        end

        # Remove the contained widget from this window
        def gtkRemoveWidget(widget)
            remove(widget)
        end
        
        def showBusy(bool)
            if bool
                self.window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::WATCH))
            else
                self.window.set_cursor(nil)
            end
            Gdk::flush
        end
    end
end
