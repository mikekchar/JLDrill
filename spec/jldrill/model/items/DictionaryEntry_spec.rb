# encoding: utf-8
require 'jldrill/model/items/DictionaryEntry'

module JLDrill

	describe DictionaryEntry do
	
		before(:each) do
            @word = DictionaryEntry.new
            # The word needs a reading to be valid
            @word.should_not be_valid
		end
		
		it "should have a kanji/reading key" do
            @word.kanji = "雨"
            @word.should_not be_valid
            @word.reading = "あめ"
            @word.should be_valid
            @word.kanji = ""
            @word.should be_valid
		end

    end
end
