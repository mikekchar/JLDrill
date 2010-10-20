require 'jldrill/model/moji/Kanji'
require 'jldrill/model/moji/Radical'
require 'jldrill/model/Config'

module JLDrill

	describe Kanji do
	
		it "should be able to parse an entry from the kanji file" do
			entryText = "一|B1 G1 S1 F2 N1 V1 H3341 DK2105 L1 IN2 P4-1-4 I0a1.1 Yyi1|イチ イツ ひと- ひと.つ|かず い いっ いる かつ かづ てん はじめ ひ ひとつ まこと||one\n"
			entry = Kanji.parse(entryText)
			
			entry.should_not be_nil
			entry.character.should eql("一")
			entry.meanings.size.should be(1)
			entry.meanings[0].should eql("one")
			entry.bushu.should be(1)
			entry.grade.should be(1)
			entry.strokes.should be(1)
			entry.to_s.should eql("一 [イチ イツ ひと- ひと.つ]\none\n\nGrade 1, Strokes 1\nBushu 1\n")
		end
	end

	describe KanjiList do
		it "should be able to parse a file in a string" do
			string = 
%Q[一|B1 G1 S1 F2 N1 V1 H3341 DK2105 L1 IN2 P4-1-4 I0a1.1 Yyi1|イチ イツ ひと- ひと.つ|かず い いっ いる かつ かづ てん はじめ ひ ひとつ まこと||one
丁|B1 G3 S2 F1312 N2 V2 H3348 DK2106 L91 IN184 P4-2-1 I0a2.4 Yding1 Yzheng1|チョウ テイ チン トウ チ ひのと|||street, ward, town, counter for guns, tools, leaves or cakes of something, even number, 4th calendar sign
丂|B1 S2 P4-2-1 Ykao3|コウ さまた.げられる|||obstruction of breath (qi) as it seeks release, variant of other characters
七|B1 G1 S2 F115 N261 V3 H3362 DK2109 L7 IN9 P4-2-2 I0a2.13 Yqi1|シチ なな なな.つ なの|し しっ な ひち||seven
丄|B1 S2 P4-2-2 Yshang4 Yshang3|ジョウ ショウ うえ うわ- かみ あ.げる あ.がる あ.がり のぼ.る のぼ.せる のぼ.す よ.す|||above
丅|B1 S2 P4-2-1 Yxia4|カ ゲ した しも もと さ.げる さ.がる くだ.る くだ.す くだ.さる お.ろす お.りる|||under, underneath, below, down, inferior, bring down
]
			list = KanjiList.fromString(string)
			list.should_not be_nil
			list.size.should be(6)
			list[0].character.should eql("一")
			list[0].meanings.size.should be(1)
			list[0].meanings[0].should eql("one")
			list[0].bushu.should be(1)
			list[0].grade.should be(1)
			list[0].strokes.should be(1)
		end

		it "should be able to parse a file on disk" do
			list = KanjiList.fromFile(JLDrill::Config::getDataDir + 
			                                "/tests/kanji.dat")
			list.should_not be(nil)
			list.size.should be(100)
			kanji = list.findChar("一")
			kanji.should_not be_nil
		end

	end
end
