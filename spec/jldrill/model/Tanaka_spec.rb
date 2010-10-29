# -*- coding: utf-8 -*-
require 'jldrill/model/Tanaka'
require 'jldrill/model/Config'

module JLDrill::Tanaka
    describe Reference do

        it "should be able to parse an entry from the Reference file" do
            a =  "A: なんですか？\tWhat is it?#ID=203\n"
            b = "B: 何{なん} です か\n"
            tanaka = Reference.new
            tanaka.lines = [a,b]
            tanaka.numSentences.should be(0)
            tanaka.numWords.should be(0)
            tanaka.parse

			# It should not dispose of the lines after parsing because it needs then for searching
			tanaka.lines.should_not eql([])

            tanaka.numSentences.should be(1)
            tanaka.numWords.should be(3)
            sentences = tanaka.search("です", nil)
            sentences.should_not be_nil
            sentences.should_not be_empty
            sentences.size.should be(1)
            sentences[0].to_s.should eql("203: です\n\tなんですか？\n\tWhat is it?")
            sentences = tanaka.search("Fail", nil)
            sentences.should_not be_nil
            sentences.should be_empty
            sentences = tanaka.search("何", "なに")
            sentences.should_not be_empty
            sentences.size.should be(1)
            sentences[0].to_s.should eql("203: 何{なん}\n\tなんですか？\n\tWhat is it?")            
        end

        it "should be able to parse Words" do
            phrase= "this(is)[1]{fun}~"
            m = Reference::WORD_RE.match(phrase)
            m.should_not be_nil
            m[1].should eql("this(is)")
        end

        it "should be able to parse the reading" do
            a = "A: どう為るの？\tWhat are you going to do?#ID=203\n"
            b = "B: 如何(どう)[1]{どう}~ 為る(する) の\n"
            tanaka = Reference.new
            tanaka.lines = [a,b]
            tanaka.parseLines(a, b, 0)
            tanaka.numSentences.should eql(1)
            tanaka.numWords.should eql(3)
            # If there is no kanji it should search for the
            # reading in the kanji
            tanaka.search(nil, "の").size.should eql(1)
            # If there is a reading in the Reference it should only find
            # words with both the kanji and reading
            tanaka.search("如何","どう").size.should eql(1)
            tanaka.search("如何",nil).size.should eql(0)
            tanaka.search(nil,"どう").size.should eql(0)
            tanaka.search("為る", "する").size.should eql(1)
        end

        it "should split sentences into Japanese and English parts" do
            sentence = "どう為るの？\tWhat are you going to do?#ID=203" 
            a =  "A: #{sentence}\n"
            b = "B: 如何(どう)[1]{どう}~ 為る(する) の\n"
            tanaka = Reference.new
            tanaka.lines = [a,b]
            tanaka.parseLines(a, b, 0)
            tanaka.numSentences.should eql(1)
            tanaka.numWords.should eql(3)
            " 如何(どう)".start_with?(" 如何(どう)").should be_true
            s = tanaka.search("如何", "どう")
            s[0].to_s.should eql("203: 如何(どう)[1]{どう}~\n\tどう為るの？\n\tWhat are you going to do?")
            s[0].english.should eql("What are you going to do?")
            s[0].japanese.should eql("どう為るの？")
            s[0].id.should eql(203)
        end

        it "should be able to parse multiple entries" do
            file = %Q[A: ＆という記号は、ａｎｄを指す。	The sign '&' stands for 'and'.#ID=1
B: と言う{という}~ 記号~ は を 指す[03]~
A: ＆のマークはａｎｄの文字を表す。	The mark "&" stands for "and".#ID=2
B: 乃{の} マーク[01] は 乃{の} 文字[01] を 表す[03]~
A: （自転車に乗って）フーッ、この坂道はきついよ。でも帰りは楽だよね。	(On a bicycle) Whew! This is a tough hill. But coming back sure will be a breeze.#ID=3
B: 自転車 に 乗る[01]{乗って} 此の{この} 坂道~ は[02] きつい[01]~ よ でも[01] 帰り は[02]~ 楽 だ よ ね[01]
A: 実のところ物価は毎週上昇している。	As it is, prices are going up every week.#ID=4
B: 実のところ 物価 は[01] 毎週 上昇 為る(する)[09]{している}
A: 〜と痛切に感じている。	I was acutely aware that..#ID=5
B: と 痛切{痛切に} 感じる{感じている}
A: 〜にも一面の真理がある。	There is a certain amount of truth in ~.#ID=6
B: にも 一面[03] 乃{の} 真理 が[01] 有る[01]{ある}
A: 処方箋をもらうために医者に行きなさい。	Go to the doctor to get your prescription!#ID=7
B: 処方箋~ を 貰う[01]{もらう} 為に{ために} 医者 に 行く[01]{行き} なさい
A: 「１７歳の時スクーナー船で地中海を航海したわ」彼女はゆっくりと注意深く言う。 [F]	"I sailed around the Mediterranean in a schooner when I was seventeen," she recited slowly and carefully.#ID=8
B: 才[01]{歳}~ 乃{の} 時(とき)[01] スクーナー~ 船[01] で 地中海 を 航海 為る(する)[09]{した} わ 彼女[01] は[01] ゆっくり{ゆっくりと} 注意深い{注意深く} 言う]
            tanaka = Reference.new
            tanaka.numSentences.should be(0)
            tanaka.numWords.should be(0)
			tanaka.lines = file.split("\n")
            tanaka.parse

			# It should not dispose of the lines after parsing because it needs them for searching
			tanaka.lines.should_not eql([])
            tanaka.loaded?.should be_true

            tanaka.numSentences.should be(8)
            tanaka.numWords.should be(52)
			haSentences = tanaka.search(nil, "は")
			haSentences.size.should be(6)
        end

        it "should be able to read the file from disk" do
            tanaka = Reference.new
			tanaka.load(File.join(JLDrill::Config::DATA_DIR, 
                                  "tests/examples.utf"))
            tanaka.parse

			tanaka.lines.should_not eql([])

			tanaka.numSentences.should be(100)
			tanaka.numWords.should be(354)
		end

		it "should be able to read the file in chunks" do
			tanaka = Reference.new
			tanaka.lines.size.should be(0)
			tanaka.file = (File.join(JLDrill::Config::DATA_DIR, 
                                     "tests/examples.utf"))
			tanaka.readLines
			tanaka.lines.size.should be(200)
			# Not EOF yet
			tanaka.parseChunk(20).should eql(false)
			tanaka.fraction.should eql(0.10)
			tanaka.parseChunk(20).should eql(false)
			tanaka.fraction.should eql(0.20)
			# Read to the EOF
			tanaka.parseChunk(1000).should eql(true)

            tanaka.loaded?.should be_true
			tanaka.lines.should_not eql([])

			tanaka.numSentences.should eql(100)
			tanaka.numWords.should be(354)
		end
    end
end
