# encoding: utf-8
require 'jldrill/model/ExampleSentence'

module JLDrill

  describe ExampleSentence do
    subject(:example) do
      ExampleSentence.new()
    end

    it "has a key" do
      # It is nil, but the reader_attr needs to be there
      expect(example.key).to be_nil
    end

    it "defines #nativeLanguage and #tagetLanguage" do
      # The base class defines a null default
      expect(example.nativeLanguage).to eq("")
      expect(example.targetLanguage).to eq("")
    end

    it "shows definitions for nativeOnly" do
      expect(subject).to receive(:key)
      expect(subject).to receive(:nativeLanguage)
      subject.nativeOnly_to_s()
    end

    it "shows definitions for targetOnly" do
      expect(subject).to receive(:key)
      expect(subject).to receive(:targetLanguage)
      subject.targetOnly_to_s()
    end

    it "shows both target and native in default case" do
      expect(subject).to receive(:key)
      expect(subject).to receive(:targetLanguage)
      expect(subject).to receive(:nativeLanguage)
      subject.to_s()
    end
  end
end
