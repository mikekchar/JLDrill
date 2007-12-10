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
require '../lib/jldrill/Vocabulary'

class VocabularyTest < Test::Unit::TestCase

  def setup
    @empty = Vocabulary.new()
    dAme = ["rain", "more rain"]
    mAme = ["n", "P"]
    @ame = Vocabulary.new("雨", "あめ", dAme, mAme, "雨がふっています", 27)
    @ame.score = 3
    @ame.bin = 2
    @ame.level = 1
    dKaze = ["wind"]
    @kaze = Vocabulary.new("風", "かぜ", dKaze)
    @kaze.score = 1
    @kaze.bin = 3
    @kaze.level = 2
  end

  def teardown
    # Nothing to do here
  end

  def test_creation
    assert_nil(@empty.kanji)
    assert_nil(@empty.reading)
    assert_nil(@empty.hint)
    assert_equal(0, @empty.score)
    assert_equal(0, @empty.bin)
    assert_equal(0, @empty.level)
    assert_equal(-1, @empty.position)
    assert_equal("", @empty.definitions)
    assert_equal("", @empty.markers)

    assert_equal("雨", @ame.kanji)
    assert_equal("あめ", @ame.reading)
    assert_equal("雨がふっています", @ame.hint)
    assert_equal(3, @ame.score)
    assert_equal(2, @ame.bin)
    assert_equal(1, @ame.level)
    assert_equal(27, @ame.position)
    assert_equal("rain, more rain", @ame.definitions)
    assert_equal("n, P", @ame.markers)

    assert_equal("風", @kaze.kanji)
    assert_equal("かぜ", @kaze.reading)
    assert_nil(@kaze.hint)
    assert_equal(1, @kaze.score)
    assert_equal(3, @kaze.bin)
    assert_equal(2, @kaze.level)
    assert_equal(-1, @kaze.position)
    assert_equal("wind", @kaze.definitions)
    assert_equal("", @kaze.markers)
  end

  def test_valid
    assert(!@empty.valid)
    assert(@ame.valid)
  end

  def test_assignment
    assert(@ame.eql?(@ame))
    assert(!@empty.eql?(@ame))
    @empty.set(@ame)
    assert(@empty.eql?(@ame))
    assert(@empty.score == @ame.score)
    assert(@empty.bin == @ame.bin)
    assert(@empty.level == @ame.level)
    assert(@empty.position == @ame.position)
  end

  def test_readWrite
    # Note: I won't test the actual format, because I don't care.  Nobody
    # is going to hand create one of these.  I just want to make sure that
    # it reads what it writes and that it's writing everything

    @empty.parse(@ame.to_s)
    assert(@empty.eql?(@ame))

    # need to test these separately since they aren't included in equality
    assert_equal(@ame.score, @empty.score)
    assert_equal(@ame.bin, @empty.bin)
    assert_equal(@ame.level, @empty.level)
  end

end
