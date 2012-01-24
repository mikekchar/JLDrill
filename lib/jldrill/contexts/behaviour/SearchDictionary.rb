# encoding: utf-8
module JLDrill::Behaviour
    # Provides the ability to search the kanji and JEDictionary.
    module SearchDictionary

        # Returns true if the Kanji dictionary is loaded
        def kanjiLoaded?
            !@parent.kanji.nil?
        end

        def findKanjiInDictionary(character)
            retVal = []
            if dictionaryLoaded?
                retVal = @parent.reference.findKanji(character)
            end
            return retVal
        end
       
        # Returns the information for a given kanji character
        def kanjiInfo(character)
            retVal = ""
            entries = findKanjiInDictionary(character)
            kanji = @parent.kanji.kanjiList.findChar(character)
            # If the kanji isn't found, it might be a simplified
            # character.  If the character was a word in the dictionary,
            # we can use the kanji entry for one of dictionary entries
            # and search the kanji information again.
            if kanji.nil? && !entries.empty?
                kanji = @parent.kanji.kanjiList.findChar(entries[0].kanji)
            end
            if !kanji.nil?
                if @parent.quiz.options.language == "Chinese"
                    retVal += kanji.withPinYinRadical_to_s(@parent.kanji.kanjiList, @parent.radicals.radicalList)
                else
                    retVal += kanji.withRadical_to_s(@parent.radicals.radicalList)
                end
                retVal += "\n\nDictionary Lookup:\n"
                retVal += entries.join("\n")
                retVal += "\n"
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
