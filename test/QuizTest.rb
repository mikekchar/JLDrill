#    JLDrill - A program to drill various aspects of the Japanese Language
#    Copyright (C) 2005  Mike Charlton
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'test/unit'
require '../lib/jldrill/Quiz'
require '../lib/jldrill/Vocabulary'

class QuizTest < Test::Unit::TestCase

  def setup
    @quiz = Quiz.new()
    dAme = ["rain", "more rain"]
    mAme = ["n", "P"]
    @ame = Vocabulary.new("雨", "あめ", dAme, mAme, "雨がふっています", 27)
    dKaze = ["wind"]
    @kaze = Vocabulary.new("風", "かぜ", dKaze)
  end

  def teardown
    if File.exists?("test.ldrill")
      File.delete("test.ldrill")
    end
  end

  def test_creation
    # Test the defaults
    assert(!@quiz.updated)  # Hmm strange default... maybe I'll change this
    assert_equal("", @quiz.savename)
    assert(!@quiz.randomOrder)
    assert_equal(2, @quiz.promoteThresh)
    assert_equal(10, @quiz.introThresh)

    assert_equal("  : Unseen: 0 Poor: 0 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    assert_equal(@quiz.status, @quiz.to_s)
    assert_equal(0, @quiz.length)
    assert_equal(0, @quiz.allVocab.length)
    assert_nil(@quiz.vocab)
  end

  def test_writers()
    assert_equal("", @quiz.savename)
    @quiz.savename = "Fun"
    assert_equal("Fun", @quiz.savename)

    assert(!@quiz.updated)

    assert(!@quiz.randomOrder)
    @quiz.randomOrder = true
    assert(@quiz.randomOrder)
    assert(@quiz.updated)
    @quiz.updated = false
    assert(!@quiz.updated)

    assert_equal(2, @quiz.promoteThresh)
    @quiz.promoteThresh = 5
    assert_equal(5, @quiz.promoteThresh)
    assert(@quiz.updated)
    @quiz.updated = false

    assert_equal(10, @quiz.introThresh)
    @quiz.introThresh = 17
    assert_equal(17, @quiz.introThresh)
    assert(@quiz.updated)
    @quiz.updated = false
  end

  def test_vocab
    assert_nil(@quiz.vocab)
    @quiz.vocab = nil
    assert_equal(0, @quiz.length)
    assert_nil(@quiz.vocab)
    @quiz.vocab = @kaze
    assert_equal(1, @quiz.length)
    assert_equal(@kaze, @quiz.vocab)
    @quiz.vocab = @ame
    assert_equal(1, @quiz.length)
    assert_equal(@kaze, @quiz.vocab)
    assert(@kaze.eql?(@ame))
    @quiz.vocab = nil
    assert_equal(1, @quiz.length)
    assert_equal(@kaze, @quiz.vocab)
    assert(@kaze.eql?(@ame))
  end

  def test_addition
    @quiz.addVocab(nil)
    assert_equal(0, @quiz.length)
    assert(!@quiz.updated)

    v = Vocabulary.new()
    # This vocabulary is not Valid, so it shouldn't be added
    assert(!v.valid)
    @quiz.addVocab(v)
    assert_equal(0, @quiz.length)
    assert(!@quiz.updated)

    @quiz.addVocab(@ame)
    assert_equal(1, @quiz.length)
    assert_equal("* : Unseen: 1 Poor: 0 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    assert(@quiz.updated)

    @quiz.addVocab(@kaze)
    assert_equal(2, @quiz.length)
    assert_equal("* : Unseen: 2 Poor: 0 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    assert(@quiz.updated)

    list = @quiz.allVocab()
    assert_equal(2, list.length)

    # A bit silly because Ruby arrays push and pop things in reverse order.
    assert(@kaze.eql?(list[0]))
    assert(@ame.eql?(list[1]))
  end

  def checkSave(status)
    @quiz.info = "This is a test\n"
    @quiz.info += "  Hope that it works\n"
    @quiz.name = "TestQuiz"
    assert(@quiz.save)
    assert(File.exists?("test.ldrill"))
    assert(!@quiz.updated)
    
    assert(Quiz.drillFile?("test.ldrill"))
    
    newQuiz = Quiz.new()
    assert(newQuiz.load("test.ldrill"))
    assert_equal("TestQuiz", newQuiz.name)
    assert_equal("This is a test\n  Hope that it works\n", @quiz.info)
    
    assert_equal(status, newQuiz.status)
    assert_equal(2, newQuiz.length) 
    newQuiz.reset()
    list = newQuiz.allVocab()
    assert(@kaze.eql?(list[0]))
    assert(@ame.eql?(list[1]))
  end

  def test_save
    @quiz.savename = ""
    assert(!@quiz.save)
    assert(!@quiz.updated)
    
    @quiz.savename = "test.ldrill"
    assert(!@quiz.save)
    assert(!File.exists?("test.ldrill"))
    assert(!@quiz.updated)

    @quiz.addVocab(@ame)
    @quiz.addVocab(@kaze)
    assert(@quiz.updated)

    @quiz.savename = ""
    assert(!@quiz.save)
    assert(!File.exists?("test.ldrill"))
    assert(@quiz.updated)

    @quiz.savename = "test.ldrill"
    @quiz.updated = false
    assert(!@quiz.save)
    assert(!File.exists?("test.ldrill"))
    assert(!@quiz.updated)

    @quiz.updated = true
    checkSave("* TestQuiz: Unseen: 2 Poor: 0 Fair: 0 Good: 0 Excellent: 0 - (2,10)")

    @quiz.randomVocab!()
    assert_equal("* TestQuiz: Unseen: 1 Poor: 1 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    checkSave("* TestQuiz: Unseen: 1 Poor: 1 Fair: 0 Good: 0 Excellent: 0 - (2,10)")

    @quiz.promote()
    assert_equal("* TestQuiz: Unseen: 1 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    checkSave("* TestQuiz: Unseen: 1 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)")

    @quiz.promote()
    @quiz.promote()
    @quiz.promote()
    assert_equal("* TestQuiz: Unseen: 1 Poor: 0 Fair: 0 Good: 1 Excellent: 0 - (2,10)",
                 @quiz.status)
    checkSave("* TestQuiz: Unseen: 1 Poor: 0 Fair: 0 Good: 1 Excellent: 0 - (2,10)")

    @quiz.promote()
    assert_equal("* TestQuiz: Unseen: 1 Poor: 0 Fair: 0 Good: 0 Excellent: 1 - (2,10)",
                 @quiz.status)
    checkSave("* TestQuiz: Unseen: 1 Poor: 0 Fair: 0 Good: 0 Excellent: 1 - (2,10)")

    # take advantage of the fact that we never choose the same vocab twice
    @quiz.randomVocab!()
    assert_equal("* TestQuiz: Unseen: 0 Poor: 1 Fair: 0 Good: 0 Excellent: 1 - (2,10)",
                 @quiz.status)
    checkSave("* TestQuiz: Unseen: 0 Poor: 1 Fair: 0 Good: 0 Excellent: 1 - (2,10)")
    
  end

  def test_prototion
    @quiz.addVocab(@ame)
    @quiz.addVocab(@kaze)
    assert_equal("* : Unseen: 2 Poor: 0 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)

    @quiz.randomVocab!()
    vocab = @quiz.vocab
    assert_equal(1, vocab.bin)
    assert_equal("* : Unseen: 1 Poor: 1 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(2, vocab.bin)
    assert_equal("* : Unseen: 1 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(2, vocab.bin)
    assert_equal(1, vocab.level)
    assert_equal("* : Unseen: 1 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(2, vocab.bin)
    assert_equal(2, vocab.level)
    assert_equal("* : Unseen: 1 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(3, vocab.bin)
    assert_equal("* : Unseen: 1 Poor: 0 Fair: 0 Good: 1 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(4, vocab.bin)
    assert_equal("* : Unseen: 1 Poor: 0 Fair: 0 Good: 0 Excellent: 1 - (2,10)",
                 @quiz.status)
    @quiz.randomVocab!()
    assert(vocab != @quiz.vocab)
    assert_equal(1, @quiz.vocab.bin)
    assert_equal("* : Unseen: 0 Poor: 1 Fair: 0 Good: 0 Excellent: 1 - (2,10)",
                 @quiz.status)
    @quiz.randomVocab!()
    @quiz.demote()
    assert_equal(1, vocab.bin)
    assert_equal("* : Unseen: 0 Poor: 2 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)    
  end

  def test_changeLevel
    @quiz.addVocab(@ame)
    @quiz.addVocab(@kaze)
    @quiz.randomVocab!()
    vocab = @quiz.vocab
    assert_equal(1, vocab.bin)
    assert_equal(0, vocab.level)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(2, vocab.bin)
    assert_equal(0, vocab.level)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(2, vocab.bin)
    assert_equal(1, vocab.level)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(2, vocab.bin)
    assert_equal(2, vocab.level)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(3, vocab.bin)
    assert_equal(2, vocab.level)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(4, vocab.bin)
    assert_equal(2, vocab.level)
    @quiz.promote()
    assert_equal(vocab, @quiz.vocab)
    assert_equal(4, vocab.bin)
    assert_equal(2, vocab.level)
  end

  def test_nonDrillFile
    # just show that an edict file is not a drill file
    assert(!Quiz.drillFile?("../data/jldrill/dict/edict.utf"))
  end

  def test_getBin
    @quiz.addVocab(@ame)
    @quiz.addVocab(@kaze)

    assert_equal(0, @quiz.getBin)
    @quiz.randomVocab!()
    assert_equal(0, @quiz.getBin)
    @quiz.randomVocab!()
    # unseen bin is empty now
    assert(0 != @quiz.getBin)
    8.times do 
      v = Vocabulary.new()
      v.set(@ame)
      @quiz.addVocab(v)
      assert_equal(0, @quiz.getBin)
      @quiz.promote()
    end
    v = Vocabulary.new()
    v.set(@ame)
    @quiz.addVocab(v)
    # hit introThresh (defaults to 10)
    assert(0 != @quiz.getBin)
    assert_equal("* : Unseen: 1 Poor: 10 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.reset()
    assert_equal("* : Unseen: 11 Poor: 0 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.allVocab.each { |vocab|
      assert_equal(0, vocab.score)
      assert_equal(0, vocab.bin)
      assert_equal(0, vocab.level)
    }
    assert_equal(0, @quiz.getBin)
  end

  def test_getVocab()
    assert_equal(0, @quiz.length )
    assert_nil(@quiz.vocab)
    assert_nil(@quiz.getVocab())
    @quiz.randomOrder = false
    @quiz.addVocab(@ame)
    @quiz.addVocab(@kaze)
    assert_equal(@ame, @quiz.getVocab)
  end

  def test_randomVocab!()
    assert_nil(@quiz.vocab)
    assert_nil(@quiz.getVocab())
    @quiz.randomOrder = false
    @quiz.addVocab(@ame)
    @quiz.addVocab(@kaze)
    @quiz.randomVocab!
    assert_equal(@ame, @quiz.vocab)
    @quiz.randomVocab!
    assert_equal(@kaze, @quiz.vocab)
  end

  def test_correct
    @quiz.addVocab(@ame)
    @quiz.randomVocab!
    0.upto(@quiz.promoteThresh - 1) do |i|
      assert_equal(@ame, @quiz.vocab)
      assert_equal(i, @ame.score)
      assert_equal("* : Unseen: 0 Poor: 1 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                   @quiz.status)
      @quiz.updated = false
      @quiz.correct()
      assert(@quiz.updated)
    end
    assert_equal(0, @ame.score)
    assert_equal("* : Unseen: 0 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    0.upto(@quiz.promoteThresh - 2) do |i|
      assert_equal(@ame, @quiz.vocab)
      assert_equal(i, @ame.score)
      assert_equal("* : Unseen: 0 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)",
                   @quiz.status)
      @quiz.updated = false
      @quiz.correct()
      assert(@quiz.updated)
    end
    assert_equal(@quiz.promoteThresh - 1, @ame.score)
    assert_equal("* : Unseen: 0 Poor: 0 Fair: 1 Good: 0 Excellent: 0 - (2,10)",
                 @quiz.status)
    @quiz.updated = false
    @quiz.incorrect()
    assert(@quiz.updated)
    assert_equal(0, @ame.score)
    assert_equal("* : Unseen: 0 Poor: 1 Fair: 0 Good: 0 Excellent: 0 - (2,10)",
                   @quiz.status)
    
  end

end
