require 'Kanji'

module JLDrill

	describe KanjidicEntry do
	
		it "should be able to parse an entry from the kanjidic file" do
			entryText = "亜 3021 U4e9c B1 C7 G8 S7 XJ05033 F1509 N43 V81 H3540 DK2204 L1809 K1331 O525 DO1788 MN272 MP1.0525 E997 IN1616 DJ1818 DG35 I0a7.14 Q1010.6 DR3273 Yya4 Wa ア アシア つ.ぐ T1 や つぎ つぐ {Asia} {rank next} {come after} {-ous} "
			entry = KanjidicEntry.parse(entryText)
			
			entry.should_not be_nil
			entry.character.should be_eql("亜")
			entry.jisCode.should be(0x3021)
			entry.meanings.size.should be(4)
			entry.meanings[0].should be_eql("Asia")
			entry.meanings[1].should be_eql("rank next")
			entry.meanings[2].should be_eql("come after")
			entry.meanings[3].should be_eql("-ous")
			entry.bushu.should be(1)
		end
		
		it "will remind me to submit this bug" do
			entryText = "亜 3021 U4e9c B1 C7 G8 S7 XJ05033 F1509 N43 V81 H3540 DK2204 L1809 K1331 O525 DO1788 MN272 MP1.0525 E997 IN1616 DJ1818 DG35 I0a7.14 Q1010.6 DR3273 Yya4 Wa ア アシア つ.ぐ T1 や つぎ つぐ {Asia} {rank next} {come after} {-ous} "
			
			fun = entryText.slice(/\ \{.*$/)
			entryText.slice!(/\ \{.*$/)
			fun.should be_eql(entryText)
		end			

	end
end
