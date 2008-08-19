require 'jldrill/model/Kanji'
require 'jldrill/model/Radical'

module JLDrill

	describe KanjidicEntry do
	
		it "should be able to parse an entry from the kanjidic file" do
			entryText = "亜 3021 U4e9c B1 C7 G8 S7 XJ05033 F1509 N43 V81 H3540 DK2204 L1809 K1331 O525 DO1788 MN272 MP1.0525 E997 IN1616 DJ1818 DG35 I0a7.14 Q1010.6 DR3273 Yya4 Wa ア アシア つ.ぐ T1 や つぎ つぐ {Asia} {rank next} {come after} {-ous} "
			entry = KanjidicEntry.parse(entryText, mock("RadKFile"))
			
			entry.should_not be_nil
			entry.character.should be_eql("亜")
			entry.jisCode.should be(0x3021)
			entry.meanings.size.should be(4)
			entry.meanings[0].should be_eql("Asia")
			entry.meanings[1].should be_eql("rank next")
			entry.meanings[2].should be_eql("come after")
			entry.meanings[3].should be_eql("-ous")
			entry.bushu.should be(1)
			entry.grade.should be(8)
		end

		it "should be able to parse entries with hex JIS codes" do
			entryText = "一 306C U4e00 B1 G1 S1 XJ05021 F2 N1 V1 H3341 DK2105 L1 K4 O3 DO1 MN1 MP1.0001 E1 IN2 DS1 DF1 DH1 DT1 DC1 DJ1 DB1.A DG1 I0a1.1 Q1000.0 DR3072 Yyi1 Wil イチ イツ ひと- ひと.つ T1 かず い いっ いる かつ かづ てん はじめ ひ ひとつ まこと {one}"
			entry = KanjidicEntry.parse(entryText, mock("RadKFile"))
			
			entry.should_not be_nil
			entry.character.should be_eql("一")
			entry.jisCode.should be(0x306C)
			entry.meanings.size.should be(1)
			entry.meanings[0].should be_eql("one")
			entry.bushu.should be(1)
			entry.grade.should be(1)
		end

		it "will remind me when this bug is fixed" do
			entryText = "亜 3021 U4e9c B1 C7 G8 S7 XJ05033 F1509 N43 V81 H3540 DK2204 L1809 K1331 O525 DO1788 MN272 MP1.0525 E997 IN1616 DJ1818 DG35 I0a7.14 Q1010.6 DR3273 Yya4 Wa ア アシア つ.ぐ T1 や つぎ つぐ {Asia} {rank next} {come after} {-ous} "
			
			fun = entryText.slice(/\ \{.*$/)
			entryText.slice!(/\ \{.*$/)
			fun.should_not be_eql(entryText)
		end
		
		it "should be able to parse comments" do
			entryText = "# KANJIDIC JIS X 0208 Kanji Information File/See the kanjidic_doc.html file for full details/Copyright Electronic Dictionary Research & Development Group - 2006/2007-02-10/"
			entry = KanjidicComment.parse(entryText)

			entry.should_not be_nil
			entry.contents.should be_eql(" KANJIDIC JIS X 0208 Kanji Information File/See the kanjidic_doc.html file for full details/Copyright Electronic Dictionary Research & Development Group - 2006/2007-02-10/")
		end			
	end

	describe KanjidicFile do
		it "should be able to parse a file in a string" do
			fileString = %Q[#
# KANJIDIC JIS X 0208 Kanji Information File/See the kanjidic_doc.html file for full details/Copyright Electronic Dictionary Research & Development Group - 2006/2007-02-10/
亜 3021 U4e9c B1 C7 G8 S7 XJ05033 F1509 N43 V81 H3540 DK2204 L1809 K1331 O525 DO1788 MN272 MP1.0525 E997 IN1616 DJ1818 DG35 I0a7.14 Q1010.6 DR3273 Yya4 Wa ア アシア つ.ぐ T1 や つぎ つぐ {Asia} {rank next} {come after} {-ous} 
唖 3022 U5516 B30 S10 XJ13560 XJ14D64 N939 V795 L2958 MN3743 MP2.1066 I3d8.3 Q6101.7 Yya1 Wa ア アク おし {mute} {dumb} 
娃 3023 U5a03 B38 S9 V1213 L2200 MN6262 MP3.0707 I3e6.5 Q4441.4 Ywa2 Wwae Wwa ア アイ ワ うつく.しい T1 い {beautiful} 
阿 3024 U963f B170 G9 S8 XN5008 F1126 N4985 V6435 H346 DK256 L1295 K1515 O569 MN41599 MP11.0798 IN2258 I2d5.6 Q7122.0 Ya1 Ye1 Ya5 Ya2 Ya4 Wa Wog ア オ おもね.る T1 くま ほとり あず あわ おか きた な {Africa} {flatter} {fawn upon} {corner} {nook} {recess} 
]
			radkfile = RadKFile.open("data/jldrill/dict/radkfile.utf")
			radkfile.should_not be_nil
			file = KanjidicFile.fromString(fileString, radkfile)
			file.should_not be_nil
			file.size.should be(4)
			file[0].character.should be_eql("亜")
			file[0].meanings.size.should be(4)
			file[0].meanings[0].should be_eql("Asia")
			file[0].meanings[1].should be_eql("rank next")
			file[0].meanings[2].should be_eql("come after")
			file[0].meanings[3].should be_eql("-ous")
			file[0].bushu.should be(1)
			file[0].grade.should be(8)
			file[1].character.should be_eql("唖")
			file[1].meanings.size.should be(2)
			file[1].meanings[0].should be_eql("mute")
			file[1].meanings[1].should be_eql("dumb")
			file[1].bushu.should be(30)
			file[1].grade.should be(nil)
			file[0].radicals.size.should be(3)
			file[0].radicals.should include("一")
			file[0].radicals.should include("｜")
			file[0].radicals.should include("口")
			file[1].radicals.size.should be(4)
			file[1].radicals.should include("一")
			file[1].radicals.should include("｜")
			file[1].radicals.should include("口")
			# I don't know why this is in the list, but it actually is.  It's not a bug.
			file[1].radicals.should include("刈")
			file[1].to_s.should be_eql("唖 Gr: * * (一, ｜, 刈, 口)\nmute, dumb")
			file.to_s.should be_eql("亜 Gr: 8 * (一, ｜, 口)\nAsia, rank next, come after, -ous\n唖 Gr: * * (一, ｜, 刈, 口)\nmute, dumb\n娃 Gr: * * (土, 女)\nbeautiful\n阿 Gr: 9 * (亅, 口, 阡)\nAfrica, flatter, fawn upon, corner, nook, recess")
		end

		it "should be able to parse a file on disk" do
#			file = KanjidicFile.open("data/jldrill/dict/kanjidic.utf", RadKFile.open("data/jldrill/dict/radkfile.utf"))
#			file.should_not be(nil)
#			file.size.should be(6355)
#			file2 = file.select do |entry|
#				entry.grade == 1
#			end
		end

	end
end
