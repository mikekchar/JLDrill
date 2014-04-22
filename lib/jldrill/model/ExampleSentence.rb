# encoding: utf-8

module JLDrill
  # An example sentence.  Each sentence has a key indicating the vocabulary
  # usage that was searched for to generate the Example Sentence.
  class ExampleSentence
    attr_reader :key

    def initialize()
      @key = nil
    end

    # Returns the version of the sentence in the user's native language
    # Please override in the concrete version
    def nativeLanguage()
      return ""
    end

    # Returns the version of the sentence in the language being studied
    # Please override in the concrete version
    def targetLanguage()
      return ""
    end

    def nativeOnly_to_s()
      return "#{key}\n\t#{self.nativeLanguage}"
    end

    def targetOnly_to_s()
      return "#{key}\n\t#{self.targetLanguage}"
    end

    def to_s()
      return "#{key}\n\t#{self.targetLanguage}\n\t#{self.nativeLanguage}"
    end
  end
end
