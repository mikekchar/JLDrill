# encoding: utf-8
require 'jldrill/model/Config'

module JLDrill

	describe Config do
	
	    it "should have a DATA_DIR" do
	        Config::DATA_DIR.should_not be_nil
	    end

        it "should not be using the Gem DATA_DIR in the tests" do
            Config::DATA_DIR.should eql(File.expand_path("data/jldrill"))
        end

        it "should use the Gem::datadir if set" do
            def Gem.datadir(string)
                "blah"
            end
	        Config::getDataDir.should eql(File.expand_path("blah"))
            # Reset this so the other tests don't fail
            def Gem.datadir(string)
                nil
            end
            Config::DATA_DIR.should eql(File.expand_path("data/jldrill"))
        end

        def should_resolve(filename)
            Config::resolveDataFile(filename).should_not eql(nil)
        end

        it "should resolve data files according to the load path" do
            should_resolve(Config::QUIZ_DIR)
            should_resolve(Config::SVG_ICON_FILE)
            should_resolve(Config::PNG_ICON_FILE)
            should_resolve(File.join(Config::DICTIONARY_DIR,
                                     Config::DICTIONARY_FILE))
            should_resolve(Config::KANJI_FILE)
            should_resolve(Config::RADICAL_FILE)
            should_resolve(Config::KANA_FILE)
            should_resolve(Config::TANAKA_FILE)
            should_resolve(Config::DEINFLECTION_FILE)
        end
    end
end
