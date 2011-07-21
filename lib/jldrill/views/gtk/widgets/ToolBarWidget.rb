# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/contexts/RunCommandContext'
require 'gtk2'

module JLDrill::Gtk

    class CommandView < JLDrill::RunCommandContext::CommandView
	    class ReviewModeButton < Gtk::ToggleButton
	        def initialize(view)
	            super('Review Mode')
	            @view = view
                @context = @view.context
	            connectSignals unless @view.nil?
	            set_active(false)
	        end
	        
	        def connectSignals
				signal_connect('toggled') do
					changeMode
				end
	        end
	        
	        def changeMode
	            @context.setReviewMode(active?)
	        end
	        
	        def update
	            set_active(@context.getReviewMode)
	        end
	    end
	    
        class ToolBar < Gtk::Toolbar    
            def initialize(view)
                @view = view
                @context = @view.context
                super()
                @reviewModeButton = ReviewModeButton.new(@view)

                checkImage = Gtk::Image.new(Gtk::Stock::SPELL_CHECK,
                                       Gtk::IconSize::SMALL_TOOLBAR)
                incorrectImage = Gtk::Image.new(Gtk::Stock::NO, 
                                           Gtk::IconSize::SMALL_TOOLBAR)
                correctImage = Gtk::Image.new(Gtk::Stock::YES, 
                                         Gtk::IconSize::SMALL_TOOLBAR)
                refreshImage = Gtk::Image.new(Gtk::Stock::REFRESH,
                                         Gtk::IconSize::SMALL_TOOLBAR)

                # toolbar.set_toolbar_style(Gtk::Toolbar::BOTH)
                self.append(Gtk::Stock::SAVE,
                               "Save a Drill file"
                               ) do @context.save end
                self.append(Gtk::Stock::OPEN,
                               "Open a Edict file"
                               ) do @context.open end
                self.append(Gtk::Stock::QUIT,
                               "Quit GTK LDrill"
                               ) do @context.quit end
                self.append_space
                self.append("Check (Z)", "Check",
                               "Check the result", checkImage
                               ) do @context.check end
                self.append("Incorrect (X)", "Incorrect",
                               "Answer was incorrect", incorrectImage
                               ) do @context.incorrect end
                self.append("Correct (C)", "Correct",
                               "Answer was correct", correctImage
                               ) do @context.correct end
                self.append("Next (N)", "Next Problem",
                               "Go to a new problem without answering the current one", refreshImage
                               ) do @context.drill end
                self.append_space                               
                self.append(@reviewModeButton)
		    end

            def update
                @reviewModeButton.update
            end
        end
    end
end
