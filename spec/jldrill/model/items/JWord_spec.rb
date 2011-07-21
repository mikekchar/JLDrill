# encoding: utf-8
require 'jldrill/model/items/JWord'

module JLDrill

    # A JWord is a Japanese Word in a Japanese to English dictionary.
	describe JWord do
	
		before(:each) do
            @word = JWord.new
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
