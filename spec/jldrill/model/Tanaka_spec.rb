# -*- coding: utf-8 -*-
require 'jldrill/model/Tanaka'
require 'jldrill/model/Config'

module JLDrill
    describe Tanaka do

        it "should be able to parse an entry from the Tanaka file" do
            entryText =  "A: なんですか？\tWhat is it?#ID=203\n"
            entryText += "B: 何{なん} です か\n"
            tanaka = Tanaka.new
            tanaka.numSentences.should be(0)
            tanaka.numWords.should be(0)
            tanaka.parse(entryText.split("\n")).should be(true)
            tanaka.numSentences.should be(1)
            tanaka.numWords.should be(3)
            sentences = tanaka.search("です")
            sentences.should_not be_nil
            sentences.should_not be_empty
            sentences.size.should be(1)
            sentences[0].should eql("なんですか？\tWhat is it?")
            sentences = tanaka.search("Fail")
            sentences.should_not be_nil
            sentences.should be_empty
            sentences = tanaka.search("何")
            sentences.should_not be_empty
            sentences.size.should be(1)
            sentences[0].should eql("なんですか？\tWhat is it?")            
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
            tanaka = Tanaka.new
            tanaka.numSentences.should be(0)
            tanaka.numWords.should be(0)
            tanaka.parse(file.split("\n")).should be(true)
            tanaka.numSentences.should be(8)
            tanaka.numWords.should be(52)
			haSentences = tanaka.search("は")
			haSentences.size.should be(6)
        end

        it "should be able to read the file from disk" do
            tanaka = Tanaka.new
			tanaka.load(File.join(Config::DATA_DIR, "tests/examples.utf"))
			tanaka.numSentences.should be(100)
			tanaka.numWords.should be(351)
		end
    end
end
