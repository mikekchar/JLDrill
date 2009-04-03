require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
    class OptionsWindow < Gtk::Dialog
		include Context::Gtk::Widget
        
        def initialize(view)
            @view = view
            super("Drill Options", nil,
                  Gtk::Dialog::DESTROY_WITH_PARENT,
                  [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                  [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])
            @randomOrder = Gtk::CheckButton.new("Introduce new items in random order")
            @promoteThresh = Gtk::HScale.new(1,10,1)
            @introThresh = Gtk::HScale.new(1,100,1)
            
            self.vbox.add(@randomOrder)
            self.vbox.add(Gtk::Label.new("Promote item after x correct"))
            self.vbox.add(@promoteThresh)
            self.vbox.add(Gtk::Label.new("Max actively learning items"))
            self.vbox.add(@introThresh)
        end
        
        def randomOrder=(value)
            @randomOrder.active = value
        end
        
        def randomOrder
            @randomOrder.active?
        end
        
        def promoteThresh=(value)
            @promoteThresh.value = value
        end
        
        def promoteThresh
            @promoteThresh.value.to_i
        end
        
        def introThresh=(value)
            @introThresh.value = value
        end
        
        def introThresh
            @introThresh.value.to_i
        end
        
        def set(options)
            self.randomOrder = options.randomOrder
            self.promoteThresh = options.promoteThresh
            self.introThresh = options.introThresh
        end
        
        def updateFromViewData
            set(@view.options)
        end
        
        def setViewData
            @view.optionsSet = true
            @view.options.randomOrder = self.randomOrder
            @view.options.promoteThresh = self.promoteThresh
            @view.options.introThresh = self.introThresh
        end
        
        def execute
            if run == Gtk::Dialog::RESPONSE_ACCEPT
                setViewData
            end
            @view.exit
        end
    end
end
