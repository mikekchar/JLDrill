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

            @dictionaryOptions = createDictionaryOptions
            @newSetOptions = createNewSetOptions
            @workingSetOptions = createWorkingSetOptions
            @reviewSetOptions = createReviewSetOptions
            
            self.vbox.add(@dictionaryOptions.box)
            self.vbox.add(@newSetOptions.box)
            self.vbox.add(@workingSetOptions.box)
            self.vbox.add(@reviewSetOptions.box)
        end

        # A horizontal slider with a label on the left
        class Scale
            attr_reader :box, :label, :scale

            def initialize(label, first, last, step)
                @box = Gtk::HBox.new()
                @label = Gtk::Label.new(label + ": ") 
                @scale = Gtk::HScale.new(first, last, step)
                @box.pack_start(@label, false)
                @box.pack_start(@scale, true)
            end

            # Add a widget to the right of the slider
            def add(widget, expand=true, fill=true, padding=0)
                @box.pack_start(widget, expand, fill, padding)
            end
        end

        # A vertical box with a label at the top
        class Section
            attr_reader :box, :label, :contents

            def initialize(label)
                @box = Gtk::VBox.new()
                @label = Gtk::Label.new()
                @label.set_markup("<big><b>#{label}</b></big>")
                @label.set_alignment(0.0, 0.0)
                @box.pack_start(@label, true, true)
                indent = Gtk::HBox.new()
                indent.pack_start(Gtk::VBox.new(), false, false, 25)
                @contents = Gtk::VBox.new()
                indent.pack_start(@contents, true, true)
                @box.pack_start(indent)
            end

            # Add a widget to the bottom of the box
            def add(widget)
                @contents.add(widget)
            end
        end

        def createNewSetOptions
            retVal = Section.new("New Set")
            @randomOrder = Gtk::CheckButton.new("Random Order?")
            retVal.add(@randomOrder)
            return retVal
        end

        def createReviewSetOptions
            retVal = Section.new("Review Set")
            reviewOptions = Gtk::HBox.new()
            reviewOptions.add(Gtk::Label.new("Review: "))
            @reviewReading = Gtk::CheckButton.new("Reading")
            @reviewKanji = Gtk::CheckButton.new("Kanji")
            @reviewMeaning = Gtk::CheckButton.new("Meaning")
            reviewOptions.pack_start(@reviewReading, true, true, 5)
            reviewOptions.pack_start(@reviewKanji, true, true, 5)
            reviewOptions.pack_start(@reviewMeaning, true, true, 5)
            retVal.add(reviewOptions)

            forget = Scale.new("Forget At", 0.0, 10.0, 0.1)
            @forgettingThresh = forget.scale
            retVal.add(forget.box)
            return retVal
        end

        def createWorkingSetOptions
            retVal = Section.new("Working Set")
            size = Scale.new("Size", 1, 30, 1)
            @introThresh = size.scale
            promote = Scale.new("Promote After", 1, 5, 1)
            @promoteThresh = promote.scale
            retVal.add(size.box)
            retVal.add(promote.box)
            return retVal
        end
       
        def createDictionaryOptions
            retVal = Section.new("Dictionary")
            options = Gtk::HBox.new()
            @dictionaryName = Gtk::Entry.new
            @dictionaryBrowse = Gtk::Button.new("Browse")
            @dictionaryBrowse.signal_connect('pressed') do
                @view.getDictionaryFilename
            end
            options.add(@dictionaryName)
            options.add(@dictionaryBrowse)

            retVal.add(options)
            @autoloadDic = Gtk::CheckButton.new("Autoload?")
            retVal.add(@autoloadDic)

            return retVal
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
        
        def forgettingThresh=(value)
            @forgettingThresh.value = value
        end

        def forgettingThresh
            @forgettingThresh.value.to_f
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
            self.forgettingThresh = options.forgettingThresh
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
            @view.options.forgettingThresh = self.forgettingThresh
        end
        
        def execute
            if run == Gtk::Dialog::RESPONSE_ACCEPT
                setViewData
            end
            @view.exit
        end
    end
end
