# encoding: utf-8
module JLDrill::Behaviour
    # Provides the ability to search the kanji and JEDictionary.
    module SearchDictionary

        # Returns true if the Kanji dictionary is loaded
        def kanjiLoaded?
            !@parent.kanji.nil?
        end
       
        # Returns the information for a given kanji character
        def kanjiInfo(character)
            retVal = ""
            kanji = @parent.kanji.kanjiList.findChar(character)
            if !kanji.nil?
                if @parent.quiz.options.language == "Chinese"
                    retVal += kanji.withPinYinRadical_to_s(@parent.kanji.kanjiList, @parent.radicals.radicalList)
                else
                    retVal += kanji.withRadical_to_s(@parent.radicals.radicalList)
                end
                if dictionaryLoaded?
                    retVal += "\n\nDictionary Lookup:\n"
                    retVal += @parent.reference.findKanji(kanji.character).join("\n")
                    retVal += "\n"
                end
            else
                kana = @parent.kana.kanaList.findChar(character)
                if !kana.nil?
                    retVal += kana.to_s
                end
            end
            retVal
        end

        # Returns true if the dictionary is loaded
        def dictionaryLoaded?
            @parent.reference.loaded?
        end

        # Searches the dictionary for possible words in the string.
        # Attempts to deinflect the word and provide matches.
        # Returns an array of DictionaryEntry.
        def search(string)
            matches = @parent.deinflect.match(string)
            retVal = matches.collect do |match|
                @parent.reference.findWord(match.last.dictionary)
            end.flatten

            retVal += @parent.reference.findWordsThatStart(string)
            return retVal.sort do |x,y|
                y.relevance <=> x.relevance
            end
        end
    end
end
