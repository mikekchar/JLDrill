require 'Context/Gtk/Widget'
require 'jldrill/views/gtk/CommandView'
require 'gtk2'

module JLDrill::Gtk

    class CommandView < JLDrill::CommandView
	    class ReviewModeButton < Gtk::ToggleButton
	        def initialize(view)
	            super('Review Mode')
	            @view = view
	            connectSignals unless @view.nil?
	            set_active(false)
	        end
	        
	        def connectSignals
				signal_connect('toggled') do
					changeMode
				end
	        end
	        
	        def changeMode
	            @view.setReviewMode(active?)
	        end
	        
	        def update
	            set_active(@view.getReviewMode)
	        end
	    end
	    
        class ToolBar < Gtk::Toolbar    
            def initialize(view)
                @view = view
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
                               ) do @view.save.call end
                self.append(Gtk::Stock::OPEN,
                               "Open a Edict file"
                               ) do @view.open.call end
                self.append(Gtk::Stock::QUIT,
                               "Quit GTK LDrill"
                               ) do @view.quit.call end
                self.append_space
                self.append("Check (Z)", "Check",
                               "Check the result", checkImage
                               ) do @view.check.call end
                self.append("Incorrect (X)", "Incorrect",
                               "Answer was incorrect", incorrectImage
                               ) do @view.incorrect.call end
                self.append("Correct (C)", "Correct",
                               "Answer was correct", correctImage
                               ) do @view.correct.call end
                self.append("Next (N)", "Next Problem",
                               "Go to a new problem without answering the current one", refreshImage
                               ) do @view.drill.call end
                self.append_space                               
                self.append(@reviewModeButton)
		    end

            def update
                @reviewModeButton.update
            end
        end
    end
end
