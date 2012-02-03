require 'rake'
require 'rubygems'
require 'rspec/core/rake_task'
# Debian forces the installation of a very old version of rdoc
# in /usr/lib/ruby if you install rubygems.  So I need to override
# it here.
gem 'rdoc', ">= 2.2"
require 'rdoc/task'
require 'rake/testtask'
require 'rubygems/package_task'
require 'webgen/webgentask'
require './lib/jldrill/Version'
require 'fileutils'

#======================== Setup ================================

# Files that will be packaged
pkg_files = FileList[
  'Rakefile.rb',
  'bin/**/*', 
  'lib/**/*.rb', 
  'spec/**/*.rb',
  'web/**/*',
  'data/**/*',
  'config/**/*',
  'test_results.html',
  'TODO.org',
  'TODO.html',
  'AUTHORS',
  'COPYING',
  'README',
  'jldrill.1',
  'AppRun'
]

# Current release directory
release_dir = "jldrill-#{JLDrill::VERSION}"

# Revision of the gem file.  Increment this every time you release a gem file.
gem_revision ="1"

# Rubyforge details
rubyforge_project = "jldrill"
rubyforge_maintainer = "mikekchar@rubyforge.org"

# Spec options
rspec_opts = ['-f h -o test_results.html']
spec_pattern = 'spec/**/*_s*.rb'

# Options for running the application
ruby_opts = ["-KO", "-I./lib", "-rrubygems"]

task :default => [:spec]

desc "Run the tests (default).  Output goes to test_results.html"
RSpec::Core::RakeTask.new(:spec) do |t, args|
	t.pattern = spec_pattern
	t.ruby_opts = ruby_opts
    t.rspec_opts = rspec_opts
end

desc "Run the tests and find the code coverage.  Test results are in test_results.html.  Coverage is in coverage/index.html"
RSpec::Core::RakeTask.new(:rcov) do |t|
	t.pattern = spec_pattern
	t.rcov = true
	t.rcov_opts = ["--exclude rspec,rcov,syntax,_spec,_story,cairo,pango,gtk2,atk,glib,gdk"]
	t.rspec_opts = rspec_opts
	t.ruby_opts = ruby_opts + ["-rrspec"]
end

desc "Runs rcov but excludes the source files instead of the test files.  This is how I determine how many lines of test code I have.  Output goes to coverage/index.html"
RSpec::Core::RakeTask.new(:testSize) do |t|
	t.pattern = spec_pattern
	t.rcov = true
	t.rcov_opts = ["--exclude rspec", "--exclude rcov", "--exclude syntax",
	    "--exclude lib/Context/", "--exclude lib/jldrill/",
	    "--exclude cairo", "--exclude pango", "--exclude gtk2", "--exclude atk",
	    "--exclude glib", "--exclude gdk"]
	t.rspec_opts = rspec_opts
	t.ruby_opts = ruby_opts
end

desc "Run the application that's in the development directory (rather than one that might be installed somewhere else)."
Rake::TestTask.new(:run) do |t|
	t.test_files = FileList['bin/jldrill']
	t.ruby_opts = ruby_opts
end

desc "Build the RDOC development documentation. output goes to doc/index.html"
rd = Rake::RDocTask.new(:rdoc) do |t|
	t.rdoc_dir = 'doc'
	t.title    = "JLDrill -- Japanese Language Drill program"
	t.options << '--main' << 'README' <<
		'--title' <<  'JLDrill -- Japanese Language Drill program' 
	t.rdoc_files.include('README', 'COPYING', 'AUTHORS', 'data/jldrill/COPYING')
	t.rdoc_files.include('lib/**/*.rb')
end

gem_spec = Gem::Specification.new do |s|
    
	#### Basic information.

	s.name = 'jldrill'
    s.version = JLDrill::VERSION + "." + gem_revision
	s.summary = "Japanese Language Drill Program"
	s.description = <<-EOF
 JLDrill is a program for helping people drill various aspects of the
 Japanese and Chinese languages. Current features include a kana drill, a
 vocabulary drill, a dictionary cross reference tool, a popup
 reference with stroke order diagrams for kanji and traditional 
 chinese characters, example sentences from the
 Tatoeba database and the ability to do dictionary lookups (with
 deinflection in Japanese) by hovering the mouse over a word in the quiz or
 examples.
 NEW IN 0.6.0! Mandarin language support using the CC-CEdict dictionary
 and Tatoeba example sentences.  The popup kanji tool will display
 readings for Mandarin Chinese.  Unfortunately, the stroke order font
 only supports tranditional characters.
    EOF
    s.licenses = ['GPL-3']

	#### Which files are to be included in this gem?

	s.files = pkg_files.to_a

	#### Load-time details: library and application (you will need one or both).

    # Use these for libraries.

	s.require_path = 'lib'

	# Use these for applications.

	s.bindir = "bin"
	s.executables = ["jldrill"]
	
	#### Dependencies
    
    s.add_dependency("gtk2")

    #### Documentation and testing.

	s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
	s.rdoc_options = rd.options

    #### Author and project details.

	s.author = "Mike Charlton"
	s.email = "mikekchar@gmail.com"
	s.homepage = "http://sakabatou.dnsdojo.org"
    s.rubyforge_project = rubyforge_project
end

desc "Clean the web directory."
task :clean_web do
    FileUtils.rm_rf('webgen.cache')
    FileUtils.rm_rf('web/output')
    FileUtils.rm_rf('web/webgen.cache')
end

desc "Create the web html files.  Files are placed in web/output"
webgen_task = Webgen::WebgenTask.new('web') do |site|
    site.clobber_outdir = true
    site.config_block = lambda do |config|
        config['sources'] = [['/', "Webgen::Source::FileSystem", 'web/src']]
        config['output'] = ['Webgen::Output::FileSystem', 'web/output']
    end
end

desc "Creates the gem files for jldrill.  Packages are placed in pkg and called jldrill-<version>.gem."
package_task = Gem::PackageTask.new(gem_spec) do |pkg|
	pkg.need_zip = false
	pkg.need_tar = true
end

desc "Build the web page and upload it to Rubyforge."
task :publish => [:clean_web, :web] do
    sh "scp web/output/*.html web/output/*.css " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project
    sh "scp web/output/images/* " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project + "/images/"
end

desc "Cleans everything for a pristine source directory."
task :clean => [:clobber_package, :clobber_rdoc, :clobber_web] do
    FileUtils.rm_rf release_dir
end

desc "Clean everything, run tests, and build all the documentation."
task :build => [:clean, :spec, :rdoc, :web]

desc "Make the release directory"
task :releaseDir do
    FileUtils.mkdir release_dir
end

desc "Build the debian packages"
task :debian => [:web, :package] do
    FileUtils.mv "pkg/jldrill-#{JLDrill::VERSION}.#{gem_revision}",
            "pkg/jldrill-#{JLDrill::VERSION}"
    # Debian packages its own edict dictionary
    FileUtils.rm_r "pkg/jldrill-#{JLDrill::VERSION}/data/jldrill/dict/edict"
    sh "cd pkg; tar cvzf jldrill_#{JLDrill::VERSION}.orig.tar.gz jldrill-#{JLDrill::VERSION}"
    FileUtils.cp_r Dir.glob("debian"), "pkg/jldrill-#{JLDrill::VERSION}"
    sh "cd pkg/jldrill-#{JLDrill::VERSION}; debuild -us -uc"
end

desc "Rebuild everything, create gem and tar for JLDrill, place all distributable files in the jldrill-<version> directory.  Used for creating a new release of JLDrill.  Note: it does not publish the web page."
task :release => [:build, :releaseDir, :package, :debian] do
    FileUtils.mv Dir.glob("pkg/*.gem"), release_dir
    FileUtils.mv Dir.glob("pkg/jldrill_#{JLDrill::VERSION}*"), release_dir
    FileUtils.rm_rf "pkg"
end

desc "Alias for release.  Run this after doing a bzr update so that everything is rebuilt."
task :update => [:release]
