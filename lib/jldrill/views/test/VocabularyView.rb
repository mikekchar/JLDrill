# encoding: utf-8
require 'jldrill/contexts/ModifyVocabularyContext'

module JLDrill::Test
    class VocabularyView < JLDrill::ModifyVocabularyContext::VocabularyView
        attr_reader :destroyed, :searchUpdated, :vocabularyCleared
        attr_writer :destroyed, :searchUpdated, :vocabularyCleared

        def initialize(context, name)
            super(context, name)
            @destroyed = false
            @searchUpdated = false
            @vocabularyCleared = false
        end

        def destroy
            @destroyed = true
        end

        def updateSearch
            @searchUpdated = true
        end

        def getVocabulary
            # Not sure how to test this yet
        end

        def clearVocabulary
            @vocabularyCleared = true
        end
    end
end
