# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/contexts/RunCommandContext'
require 'gtk2'

module JLDrill::Gtk

    class CommandView < JLDrill::RunCommandContext::CommandView
        class Menu < Gtk::HBox
            attr_reader :accelGroup
            
            def initialize(view)
                @view = view
                @context = @view.context
                super()
                @accelGroup = Gtk::AccelGroup.new
                @menu = Gtk::ItemFactory.new(Gtk::ItemFactory::TYPE_MENU_BAR,
                                               '<main>', @accelGroup)
                @menuItems = [
                    ["/_File"],
                    ["/File/_New",
                        "<StockItem>",    "<control>N",     Gtk::Stock::NEW,
                        Proc.new {@context.createNew} ],
                    ["/File/_Save",
                        "<StockItem>",    "<control>S",     Gtk::Stock::SAVE, 
                        Proc.new{@context.save} ],
                    ["/File/Save _As...",
                        "<StockItem>",     "<control>A",    Gtk::Stock::SAVE, 
                        Proc.new{@context.saveAs} ],
                    ["/File/_Open...",
                        "<StockItem>",     "<control>O",    Gtk::Stock::OPEN, 
                        Proc.new{@context.open} ],
				    ["/File/A_ppend...",
        				"<Item>",          "<control>P",    nil, 
				        Proc.new{@context.appendFile} ],
                    ["/File/Load Reference _Dictionary",
                        "<Item>",          "<control>D",    nil, 
                        Proc.new{@context.loadReference} ],
					["/File/Load Tanaka _Examples",
						"<Item>",		   "<control>E", 	nil,
						Proc.new{@context.loadTanaka} ],
                    ["/File/_Quit",
                        "<StockItem>",     "<control>Q",    Gtk::Stock::QUIT, 
                        Proc.new{@context.quit} ],

                    ["/_Drill"],
                    ["/Drill/_Info...",
                        "<Item>",          "<control>I",    nil, 
                        Proc.new{@context.info} ],
                    ["/Drill/_Statistics...",
                        "<Item>",          "<alt>S",        nil, 
                        Proc.new{@context.statistics} ],
                    ["/Drill/_Next Problem",
                        "<Item>",          "N",             nil,
                        Proc.new{@context.drill} ],
                    ["/Drill/_Check",
                        "<Item>",          "Z",             nil, 
                        Proc.new{@context.check} ],
                    ["/Drill/_Incorrect",
                        "<Item>",          "X",             nil, 
                        Proc.new{@context.incorrect} ],
                    ["/Drill/_Correct",
                        "<Item>",          "C",             nil, 
                        Proc.new{@context.correct} ],
                    ["/Drill/_Learn",
                        "<Item>",          "L",             nil,
                         Proc.new{@context.learn} ],
                    ["/Drill/Show _All...",
                        "<Item>",          "<control>T",    nil, 
                        Proc.new{@context.vocabTable} ],
                    ["/Drill/_Options",
                        "<StockItem>",     "O",    Gtk::Stock::PREFERENCES, 
                        Proc.new{@context.options} ],
                    ["/Drill/_Reset",
                        "<Item>",          "<control>R",    nil, 
                        Proc.new{@context.resetQuiz} ],
                    ["/Drill/_Remove Duplicates",
                        "<Item>",          "R",    nil, 
                        Proc.new{@context.removeDups} ],

                    ["/_Vocab"],
                    ["/Vocab/_Edit...",
                        "<Item>",          "E",             nil, 
                        Proc.new{@context.editVocab} ],
                    ["/Vocab/_Add...",
                        "<Item>",          "A",             nil, 
                        Proc.new{@context.addNewVocabulary} ],
                    ["/Vocab/_Delete...",
                        "<Item>",          "D",             nil, 
                        Proc.new{@context.deleteVocab} ],


                    ["/_Help"],
                    ["/Help/Ac_knowlegements...",
                        "<Item>",          "K",             nil, 
                        Proc.new{@context.ack} ],
                    ["/Help/_About...", 
                        "<Item>",          "?",             nil, 
                        Proc.new{@context.about} ]
                ]
                @menu.create_items(@menuItems)
			    self.pack_start(@menu.get_widget('<main>'), true, true)
		    end
		end
    end
end
