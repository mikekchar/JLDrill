require 'jldrill/spec/StoryMemento'
require 'gtk2'
require 'Context/require_all'
# We're requiring all the gtk views here since that's
# what the app would normally be doing.
require_all 'jldrill/views/gtk/*.rb'

# Story functionality for Gtk.  Used as a mixin within a
# StoryMemento
module JLDrill::StoryFunctionality
	module Gtk
        # Starts Gtk and runs the code in the block.  Note it doesn't
        # quit the main loop, so you will have to call ::Gtk::main_quit
        # somewhere in the block.  See UserLoadsDictionary_story.rb
        # for an example of usage.
		def startGtk(&block)
			::Gtk.init_add do
				block.call
			end
			::Gtk.main
		end

        # Overrides the method on the object with the closure
        # that's passed in.
        def override_method(object, method, &block)
            class << object
                self
            end.send(:define_method, method, &block)
        end

        # Make the modal dialog run as if the button was pressed.	
        def enterDialogAndPressButton(dialog, button, &block)
            override_method(dialog, :run) do
                if !block.nil?
                    block.call
                end
                button
            end
            @context.enter(@mainContext)
        end

        # Enter a dialog and press OK
        def enterDialogAndPressOK(dialog, &block)
            enterDialogAndPressButton(dialog, ::Gtk::Dialog::RESPONSE_ACCEPT, 
                                      &block)
        end

        # Enter a dialog and press Cancel
        def enterDialogAndPressCancel(dialog, &block)
            enterDialogAndPressButton(dialog, ::Gtk::Dialog::RESPONSE_CANCEL, 
                                      &block)
        end

	end
end

