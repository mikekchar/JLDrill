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
            filename = File.join(File.join(Config::DATA_DIR, "tests"),
                                 "edict.utf")
            @dict.file = filename
            @dict.readLines
            @dict.lines.size.should be(1140)
            @dict.parseChunk(100)
            @dict.dataSize.should be(100)
            @dict.parsed.should be(100)
            @dict.loaded?.should be(false)
            @dict.parse

            # Find all the words beginning with a reading
            selection = @dict.findReadingsStartingWith("あ")
            selection.size.should eql(127)
            selection = @dict.findReadingsStartingWith("あめ")
            selection.size.should eql(42)
            selection = @dict.findReadingsStartingWith("あめが")
            selection.size.should eql(4)
            selection = @dict.findReadingsStartingWith("あめがbogus")
            selection.size.should eql(0)

            # Find all the words beginning with a reading
            selection = @dict.findKanjiStartingWith("目")
            selection.size.should eql(338)
            selection = @dict.findKanjiStartingWith("目を")
            selection.size.should eql(29)
            selection = @dict.findKanjiStartingWith("目を覚ます")
            selection.size.should eql(1)
            selection = @dict.findKanjiStartingWith("目をさますbogus")
            selection.size.should eql(0)

            # Should be able to find an item
            vocab = Vocabulary.create("/Kanji: 青い/Reading: あおい/Definitions: (1) blue,green,(2) pale,(3) unripe,inexperienced/Markers: adj-i,P")
            @dict.include?(vocab).should be_true
            # One character words should work as well
            vocab = Vocabulary.create("/Kanji: 目/Reading: め/Definitions: (1) eye,eyeball,(2) eyesight,(3) look,(4) experience,(5) viewpoint,(6) ordinal number suffix,(7) somewhat,-ish/Markers: n,suf,suf,P")
            @dict.include?(vocab).should be_true

            # Should not find things that aren't there
            vocab = Vocabulary.create("/Kanji: 青い/Reading: あおい/Definitions: (1) blue,green,(3) unripe,inexperienced/Markers: adj-i,P")
            @dict.include?(vocab).should be_false
            # One character words should work as well
            vocab = Vocabulary.create("/Kanji: 目/Reading: め/Definitions: (1) eye,eyeball,(2) eyesight,(3) look,(4) viewpoint,(6) ordinal number suffix,(7) somewhat,-ish/Markers: n,suf,suf,P")
            @dict.include?(vocab).should be_false

            # Should be able to find words that are at the start of a string
            @dict.findReadingsThatStart("めをさます").size.should eql(3)
            @dict.findKanjiThatStart("目を覚ます").size.should eql(4)
            @dict.findWordsThatStart("めをさます").size.should eql(3)
            @dict.findWordsThatStart("目を覚ます").size.should eql(4)
        end
    end
end
