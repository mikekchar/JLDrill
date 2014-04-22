# encoding: utf-8
require 'jldrill/model/info/AboutInfo'

module JLDrill

  describe AboutInfo do
    subject(:about) do
      AboutInfo.new()
    end

    let(:copyright_term) do
      "2005-" + Time.now.year.to_s
    end

    it "has authors" do
      expect(about.authors).to_not be_empty
    end

    it "includes me in the author list" do
      expect(about.authors).to include("Mike Charlton")
    end

    it "includes JLDrill::Version in the version" do
      expect(about.version).to match(JLDrill::VERSION)
    end

    it "includes todays year in the copyright" do
      expect(about.copyright).to match(copyright_term)
    end

    it "includes todays year in the license" do
      expect(about.license).to match(copyright_term)
    end
  end
end
