# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadFileContext'

module JLDrill

    # Load the kanji, radicals and kana files one after another.
	class LoadKanjiContext < Context::Context

        attr_reader :kanjiFile, :radicalsFile, :kanaFile
        attr_writer :kanjiFile, :radicalsFile, :kanaFile
		
		def initialize(viewBridge)
			super(viewBridge)
		    @kanjiFile = Config::resolveDataFile(Config::KANJI_FILE)
            @radicalsFile = Config::resolveDataFile(Config::RADICAL_FILE)
            @kanaFile = Config::resolveDataFile(Config::KANA_FILE)
            @loadFileContext = LoadFileContext.new(@viewBridge)
		end

        def createViews
            @mainView =  @viewBridge.VBoxView.new(self)
        end

        def destroyViews
            @mainView = nil
        end

        def loadKanji
            @loadFileContext.onExit do
                loadRadicals
            end
            @loadFileContext.enter(self, @kanji, @kanjiFile)
        end

        def loadRadicals
            @loadFileContext.onExit do
                loadKana
            end
            @loadFileContext.enter(self, @radicals, @radicalsFile)
        end

        def loadKana
            @loadFileContext.onExit do
               exitLoadKanjiContext 
            end
            @loadFileContext.enter(self, @kana, @kanaFile)
        end

        def exitLoadKanjiContext
            self.exit
        end

        def startLongEvent()
            @parent.startLongEvent()
        end

        def stopLongEvent()
            @parent.stopLongEvent()
        end

        def enter(parent, kanji, radicals, kana)
            super(parent)
            @kanji = kanji
            @radicals = radicals
            @kana = kana
            loadKanji 
        end

    end		
end
