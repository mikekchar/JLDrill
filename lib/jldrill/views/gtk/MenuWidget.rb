require 'Context/Gtk/Widget'
require 'jldrill/views/gtk/CommandView'
require 'gtk2'

module JLDrill::Gtk

    class CommandView < JLDrill::CommandView
        class Menu < Gtk::HBox
            attr_reader :accelGroup
            
            def initialize(view)
                @view = view
                super()
                @accelGroup = Gtk::AccelGroup.new
                @menu = Gtk::ItemFactory.new(Gtk::ItemFactory::TYPE_MENU_BAR,
                                               '<main>', @accelGroup)
                @menuItems = [
                    ["/_File"],
                    ["/File/_New",
                        "<StockItem>",    "<control>N",     Gtk::Stock::NEW,
                        @view.createNew ],
                    ["/File/_Save",
                        "<StockItem>",    "<control>S",     Gtk::Stock::SAVE, 
                        @view.save ],
                    ["/File/Save _As...",
                        "<StockItem>",     "<control>A",    Gtk::Stock::SAVE, 
                        @view.saveAs ],
                    ["/File/_Open...",
                        "<StockItem>",     "<control>O",    Gtk::Stock::OPEN, 
                        @view.open ],
				    ["/File/A_ppend...",
        				"<Item>",          "<control>P",    nil, 
				        @view.appendFile ],
                    ["/File/Load Reference _Dictionary...",
                        "<Item>",          "<control>D",    nil, 
                        @view.loadReference ],
                    ["/File/_Quit",
                        "<StockItem>",     "<control>Q",    Gtk::Stock::QUIT, 
                        @view.quit ],

                    ["/_Drill"],
                    ["/Drill/_Info...",
                        "<Item>",          "<control>I",    nil, 
                        @view.info ],
                    ["/Drill/_Statistics...",
                        "<Item>",          "<alt>S",        nil, 
                        @view.statistics ],
                    ["/Drill/_Next Problem",
                        "<Item>",          "N",             nil,
                        @view.drill ],
                    ["/Drill/_Check",
                        "<Item>",          "Z",             nil, 
                        @view.check ],
                    ["/Drill/_Incorrect",
                        "<Item>",          "X",             nil, 
                        @view.incorrect ],
                    ["/Drill/_Correct",
                        "<Item>",          "C",             nil, 
                        @view.correct ],
                    ["/Drill/_Learn",
                        "<Item>",          "L",             nil,
                         @view.learn ],
                    ["/Drill/Show _All...",
                        "<Item>",          "<control>T",    nil, 
                        @view.vocabTable ],
                    ["/Drill/_Options",
                        "<StockItem>",     "O",    Gtk::Stock::PREFERENCES, 
                        @view.options ],
                    ["/Drill/_Reset",
                        "<Item>",          "<control>R",    nil, 
                        @view.resetQuiz ],

                    ["/_Vocab"],
                    ["/Vocab/_Edit...",
                        "<Item>",          "E",             nil, 
                        @view.editVocab ],
                    ["/Vocab/_Add...",
                        "<Item>",          "A",             nil, 
                        @view.addNewVocabulary ],
                    ["/Vocab/_Delete...",
                        "<Item>",          "D",             nil, 
                        @view.deleteVocab ],


                    ["/_Help"],
                    ["/Help/Ac_knowlegements...",
                        "<Item>",          "K",             nil, 
                        @view.ack ],
                    ["/Help/_About...", 
                        "<Item>",          "?",             nil, 
                        @view.about ]
                ]
                @menu.create_items(@menuItems)
			    self.pack_start(@menu.get_widget('<main>'), true, true)
		    end
		end
    end
end
