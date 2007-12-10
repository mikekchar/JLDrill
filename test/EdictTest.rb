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
require 'jldrill/Vocabulary'
require 'jldrill/Edict'
require 'jldrill/HashedEdict'
require 'jldrill/config'

class EdictTest < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

#  def test_loadReference
#    @dictDir = File.join(JLDrill::Config::DATA_DIR, "dict")
#    @dictDir = File.join(@dictDir, "JLPT")
#    @filename = File.join(@dictDir,  "jlpt-voc-4-extra.utf")
#
#    edict = Edict.new(@filename)    
#    edict.read { |fraction|
#      # Nothing required here
#    }    
#    assert_equal(673, edict.length) 
#
#    hedict = HashedEdict.new(@filename)    
#    hedict.read { |fraction|
#      # Nothing required here
#    }    
#    assert_equal(673, hedict.length) 
#  end
  
  def test_Senses
  	meaning = EdictMeaning.new("This is/fun/and profitable/")
  	senses = meaning.senses
    assert_equal(1, senses.size)
    assert_equal(3, senses[0].definitions.size)
    
    meaning = EdictMeaning.new("(v5u) (1)(uk) This is/fun/(2) and profitable/(3) (really) fun/(P)/")
    senses = meaning.senses
    assert_equal(3, senses.size)
    assert_equal(2, senses[0].definitions.size)
    assert_equal(1, senses[1].definitions.size) 
    assert_equal(1, senses[2].definitions.size) 
  end

  def test_Meanings
    ed = EdictMeaning.new("fun/")
    assert_equal(1, ed.definitions.size())
    assert_equal("fun", ed.definitions[0])

    def1 = EdictMeaning.new("This is/fun/and profitable/")
    assert_equal(3, def1.definitions.size())
    assert_equal("This is", def1.definitions[0])
    assert_equal("fun", def1.definitions[1])
    assert_equal("and profitable", def1.definitions[2])

    def2 = EdictMeaning.new("(v5u) This is/fun/and profitable/")
    assert_equal(3, def2.definitions.size())
    assert_equal(1, def2.types.size())
    assert_equal("v5u", def2.types[0])
    assert_equal("This is", def2.definitions[0])
    assert_equal("fun", def2.definitions[1])
    assert_equal("and profitable", def2.definitions[2])

    def3 = EdictMeaning.new("(v5u,blah) This is/fun/and profitable/(P)/")
    assert_equal(3, def3.definitions.size())
    assert_equal(3, def3.types.size())
    assert_equal("v5u", def3.types[0])
    assert_equal("blah", def3.types[1])
    assert_equal("P", def3.types[2])
    assert_equal("This is", def3.definitions[0])
    assert_equal("fun", def3.definitions[1])
    assert_equal("and profitable", def3.definitions[2])

    def4 = EdictMeaning.new("(v5u,blah) (1) This is/(A)(B)(C) fun/(2) and profitable/(P)/")
    assert_equal(3, def4.definitions.size())
    assert_equal(6, def4.types.size())
    assert_equal("v5u", def4.types[0])
    assert_equal("blah", def4.types[1])
    assert_equal("A", def4.types[2])
    assert_equal("B", def4.types[3])
    assert_equal("C", def4.types[4])
    assert_equal("P", def4.types[5])
    assert_equal("[1] This is", def4.definitions[0])
    assert_equal("fun", def4.definitions[1])
    assert_equal("[2] and profitable", def4.definitions[2])

	def5 = EdictMeaning.new("(v5u,blah) (1)(uk) This is fun/(2) blah/(P)/")
	assert_equal(2, def5.definitions.size())
	assert_equal(4, def5.types.size())
    assert_equal("v5u", def5.types[0])
    assert_equal("blah", def5.types[1])
    assert_equal("uk", def5.types[2])
    assert_equal("P", def5.types[3])
    assert_equal("[1] This is fun", def5.definitions[0])
    assert_equal("[2] blah", def5.definitions[1])

#	def5 = EdictMeaning.new("(v5u,blah) (1)(uk) (testing) This is fun/(2) blah/(P)/")
#	assert_equal(2, def5.definitions.size())
#	assert_equal(4, def5.types.size())
#    assert_equal("v5u", def5.types[0])
#    assert_equal("blah", def5.types[1])
#    assert_equal("uk", def5.types[2])
#    assert_equal("P", def5.types[3])
#    assert_equal("[1] (testing) This is fun", def5.definitions[0])
#    assert_equal("[2] blah", def5.definitions[1])

	def6 = EdictMeaning.new("/(n) (hum) wife/(P)/")
	assert_equal(1, def6.definitions.size())
	assert_equal(3, def6.types.size())
	
	def7 = EdictMeaning.new("/(de:) (n) (1) old (pre-Meiji) budou schools/(2) part-time job (esp. high school students) (de: Arbeit)/(P)/")
	assert_equal(2, def7.senses.size())
	assert_equal(2, def7.definitions.size())
	assert_equal(3, def7.types.size())
  end
end
