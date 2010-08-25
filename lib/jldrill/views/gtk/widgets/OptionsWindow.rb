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

            @reviewOptions = Gtk::HBox.new()
            @reviewReading = Gtk::CheckButton.new("Review Reading")
            @reviewKanji = Gtk::CheckButton.new("Review Kanji")
            @reviewMeaning = Gtk::CheckButton.new("Review Meaning")
            @reviewOptions.add(@reviewReading)
            @reviewOptions.add(@reviewKanji)
            @reviewOptions.add(@reviewMeaning)

            @dictionaryOptions = Gtk::HBox.new()
            @dictionaryOptions.add(Gtk::Label.new("Dictionary"))
            @dictionaryName = Gtk::Entry.new
            @dictionaryBrowse = Gtk::Button.new("Browse")
            @dictionaryBrowse.signal_connect('pressed') do
                @view.getDictionaryFilename
            end
            @dictionaryOptions.add(@dictionaryName)
            @dictionaryOptions.add(@dictionaryBrowse)

            @autoloadDic = Gtk::CheckButton.new("Autoload Dictionary")
            @promoteThresh = Gtk::HScale.new(1,10,1)
            
            self.vbox.add(@randomOrder)
            self.vbox.add(@reviewOptions)
            self.vbox.add(Gtk::Label.new("Promote item after x correct"))
            self.vbox.add(@promoteThresh)
            self.vbox.add(Gtk::Label.new("Max actively learning items"))
            self.vbox.add(@introThresh)
            self.vbox.add(@dictionaryOptions)
            self.vbox.add(@autoloadDic)
        end
        
        def randomOrder=(value)
            @randomOrder.active = value
        end
        
        def randomOrder
            @randomOrder.active?
        end

        def reviewMeaning=(value)
            @reviewMeaning.active = value
        end
        
        def reviewMeaning
            @reviewMeaning.active?
        end

        def reviewKanji=(value)
            @reviewKanji.active = value
        end
        
        def reviewKanji
            @reviewKanji.active?
        end
        
        def reviewReading=(value)
            @reviewReading.active = value
        end
        
        def reviewReading
            @reviewReading.active?
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

        def dictionaryName=(value)
            @dictionaryName.text = value
        end

        def dictionaryName
            return @dictionaryName.text
        end

        def autoloadDic=(value)
            @autoloadDic.active = value
        end

        def autoloadDic
            @autoloadDic.active?
        end
        
        def set(options)
            self.randomOrder = options.randomOrder
            self.promoteThresh = options.promoteThresh
            self.introThresh = options.introThresh
            self.reviewMeaning = options.reviewMeaning
            self.reviewKanji = options.reviewKanji
            self.reviewReading = options.reviewReading
            if !options.dictionary.nil?
                self.dictionaryName = options.dictionary
            else
                self.dictionaryName = JLDrill::Config::DICTIONARY_NAME
            end
            self.autoloadDic = options.autoloadDic
        end
        
        def updateFromViewData
            set(@view.options)
        end
        
        def setViewData
            @view.optionsSet = true
            @view.options.randomOrder = self.randomOrder
            @view.options.promoteThresh = self.promoteThresh
            @view.options.introThresh = self.introThresh
            @view.options.reviewMeaning = self.reviewMeaning
            @view.options.reviewReading = self.reviewReading
            @view.options.reviewKanji = self.reviewKanji
            if self.dictionaryName != JLDrill::Config::DICTIONARY_NAME &&
                self.dictionaryName != ""
                @view.options.dictionary = self.dictionaryName
            else
                @view.options.dictionary = nil
            end
            @view.options.autoloadDic = self.autoloadDic
        end
        
        def execute
            if run == Gtk::Dialog::RESPONSE_ACCEPT
                setViewData
            end
            @view.exit
        end
    end
end
