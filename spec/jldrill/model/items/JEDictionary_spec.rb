# -*- coding: utf-8 -*-
require 'jldrill/model/items/JEDictionary'

module JLDrill

    # A JEDictionary is a Japanese to English Dictionary.
    # It is composed of an array of entries from an EDict
    # dictionary. These entries are parsed to create JWords.
    # The JWords can then further parse the entries to
    # create Meanings.
	describe JEDictionary do
	
		before(:each) do
            @dict = JEDictionary.new
		end
		
		it "should be able to load a dictionary using the DataFile interface" do
            filename = File.join(Config::DICTIONARY_DIR, 
                                 Config::DICTIONARY_NAME)
            @dict.file = filename
            @dict.readLines
            @dict.lines.size.should be(162808)
            @dict.parseChunk(1000)
            @dict.dataSize.should be(1000)
            @dict.parsed.should be(1000)
            @dict.loaded?.should be(false)
            @dict.parse

            # Find all the words beginning with a reading
            selection = @dict.readingsStartingWith("あ")
            selection.size.should eql(4106)
            selection = @dict.readingsStartingWith("あめ")
            selection.size.should eql(58)
            selection = @dict.readingsStartingWith("あめが")
            selection.size.should eql(5)
            selection = @dict.readingsStartingWith("あめがbogus")
            selection.size.should eql(0)
        end
    end
end
