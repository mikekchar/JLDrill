#JLDrill - Japanese Language Drill program

JLDrill is a program for helping people drill aspects of the
Japanese language using spaced repetition.

Note: JLDrill is an *old* project and has suffered from
bitrot.  It still works, but requires some understanding of
how to build ruby projects.  I'm hoping to find some time
to clean it up a bit over time.  You can consider it
alpha quality, but it is fairly feature rich if you can figure
out how to install and run it.

##Features
  * spaced repetition   
  * a dictionary cross reference tool 
  * pop-up kanji reference (inspired by rikaichan for Firefox)
  * ability to import EDICT format files (EUC or UTF8 encoded) as a drill
  * The Tanaka corpus example sentences can be shown for vocabulary
  * A popup dictionary lookup tool with deinflection (again inspired
    by rikaichan for Firefox)

Current drills include:
  * a kana drill
  * JLPT vocabulary drills (These are the old 1, 2, 3, 4 lists NOT the new
    N1, N2, N3, N4, N5 lists)

##User Documentation
Complete user documentation including installation instructions is
available in the project.  JLDrill used to be hosted on rubyforge
and the last released version (many years ago) is still there
as of this writing:
http://jldrill.rubyforge.org

##Building
More instructions will come later, but for the moment, I recommend
installing rbenv or another ruby version manager.  To install:

```
gem install bundler
bundle install
```

To run: `./AppRun`

##License

JLDrill is copyright (C) 2005-2008 Mike Charlton.  It is licensed
under version 3.0 of the GNU General Public License (GPL) Please see
the COPYING File for more details.  Previous versions of JLDrill were
released under version 2.0 of the GPL and you may choose that version
if you wish.  However version 3.0 represents a major improvement in
clearing up ambiguous details, so I highly recommend choosing GPL 3.0
if you wish to extend this software.

License information for the various support files (dictionary, drills,
etc.) are located in the data/jldrill/COPYING directory.

##TODO

The TODO file is maintained in an Emacs Org mode file.  Org mode
is a mode of emacs that allows you to easily organize data.
The original file is text based and is easily readable and
editable with any editor.  But to publish the html file you need
Emacs.  The current published HTML file is here.

##Getting Involved

While I have built JLDrill on the work of others, as an entity on its
own, I have mostly been the sole contributor.  There are many reasons for this,
but regardless I am very enthusiastic about receiving any kind of
contribution from other people.  Even if you can't write software, there
are many ways you can contribute.  I want to encourage this as much as
possible.
  
Please address any comments, suggestions, corrections and patches to:
mailto://mikekchar@gmail.com

I'm also very interested in receiving any new drills you may come up with.
Please make sure to specify the license information for any material you
send to me.
  
