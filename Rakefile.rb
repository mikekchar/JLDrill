require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rubygems'
require 'rake/gempackagetask'
require 'webgen/webgentask'
require 'lib/jldrill/Version'
require 'fileutils'

#======================== Setup ================================

# Current release directory
release_dir = "jldrill-#{JLDrill::VERSION}"

# Rubyforge details
rubyforge_project = "jldrill"
rubyforge_maintainer = "mikekchar@rubyforge.org"

# Dependencies
context_name = "context"
context_version = "0.0.19"
context_directory = "../context"

# Files that will be packaged
pkg_files = FileList[
  'Rakefile.rb',
  'bin/**/*', 
  'lib/**/*.rb', 
  'spec/**/*.rb',
  'doc/**/*',
  'web/**/*',
  'data/**/*',
  'coverage/**/*',
  'test_results.html'  
]

# The fonts are really big and you have to install it by hand anyway
pkg_files.exclude('data/jldrill/fonts/*.ttf')

# Spec options
spec_opts = ['-f html:test_results.html']
spec_files = FileList[
	'spec/**/*_spec.rb',
	'spec/**/*_story.rb'
]

# Options for running the application
ruby_opts = ["-KO", "-I./lib"]


#=============================== Tasks ===============================
#
# The default task is simply to run rspec.  The following tasks exist
#
# spec    -- Runs rspec (default)
#            Test results are printed on stdout
# rcov    -- Runs the rspec tests and performs code coverage. 
#            Test results are put in test_results.html
#            Coverage results are put in coverage/index.html
# testSize -- Runs rcov, but reports the tests instead of the
#             the production code.  I use this to count the number
#             of lines of test code.  Output goes into coverage/index.html
# run     -- Runs the application
# rdoc    -- Creates the rdoc documentation.
#            Documentation is put in doc/index.html
# package -- Creates the gem files.
#            Packages are placed in pkg/jldrill-<version>.gem
# web     -- Builds the web page
#            Web page is at web/output/index.html
# publish -- Builds the web page and uploads it to Rubyforge.
# release -- Builds everything and places the resultant files into
#            a release directory called jldrill-<version>.  Note
#            that it currently does not publish the web page
#            as I feel that should be a separate action.
# clean   -- Removes built products
# update  -- Builds the devel build.  This is the same as release
#            but is used by the main repository after a bzr update so
#            that people can browse the built items through the
#            web-dave interface 
# deb     -- Builds a debian package in the parent directory.  Note that
#            the version number is dependent upon the changelog entry
#            in the debian directory.  Also to be strictly correct your
#            jldrill source directory should be jldrill-<version number>

task :default => [:spec]

# Run the rspec tests
Spec::Rake::SpecTask.new(:spec) do |t, args|
	t.spec_files = spec_files
	t.ruby_opts = ruby_opts
    t.spec_opts = spec_opts
end

# Run the rspec tests with the code coverage program rcov
Spec::Rake::SpecTask.new(:rcov) do |t|
	t.spec_files = spec_files
	t.rcov = true
	t.rcov_opts = ["--exclude rspec", "--exclude rcov", "--exclude syntax",
	    "--exclude _spec", "--exclude /lib/Context/", "--exclude _story",
	    "--exclude cairo", "--exclude pango", "--exclude gtk2", "--exclude atk",
	    "--exclude glib", "--exclude gdk"]
	t.spec_opts = spec_opts
	t.ruby_opts = ruby_opts
end

# Runs rcov but excludes the source files instead of the test files
# This is how I determine how many lines of test code I have.
# Note, this crashes writing out the file coverage for some reason.
# It seems to be a bug in rcov.  But since I'm only interested in
# the file sizes, I don't care.
Spec::Rake::SpecTask.new(:testSize) do |t|
	t.spec_files = spec_files
	t.rcov = true
	t.rcov_opts = ["--exclude rspec", "--exclude rcov", "--exclude syntax",
	    "--exclude /lib/Context/", "--exclude lib/jldrill/",
	    "--exclude cairo", "--exclude pango", "--exclude gtk2", "--exclude atk",
	    "--exclude glib", "--exclude gdk"]
	t.spec_opts = spec_opts
	t.ruby_opts = ruby_opts
end

# Rake task to run the application that's in the development
# directory (rather than one that might be installed somewhere else).
Rake::TestTask.new(:run) do |t|
	t.test_files = FileList['bin/jldrill']
	t.ruby_opts = ruby_opts
end

# Build the RDOC documentation tree.
rd = Rake::RDocTask.new(:rdoc) do |t|
	t.rdoc_dir = 'doc'
	t.title    = "JLDrill -- Japanese Language Drill program"
	t.options << '--inline-source' <<
		'--main' << 'README' <<
		'--title' <<  'JLDrill -- Japanese Language Drill program' 
	t.rdoc_files.include('README', 'TODO.org', 'COPYING', 'AUTHORS', 'data/jldrill/COPYING')
	t.rdoc_files.include('lib/**/*.rb')
end

# Build tar, zip and gem files.
# NOTE: The name of this task is automatically set to :package
gem_spec = Gem::Specification.new do |s|
    
	#### Basic information.

	s.name = 'jldrill'
	s.version = JLDrill::VERSION
	s.summary = "Japanese Language Drill Program"
	s.description = <<-EOF
        JLDrill is a program for helping people drill aspects of the
        Japanese language using spaced repetition.  It features a
        dictionary cross reference tool, a pop-up kanji reference
        (inspired by rikaichan for Firefox), and the ability to
        import EDICT format files (EUC or UTF8 encoded).  Included
        drills: kana, JLPT, and grammar (unfinished).
    EOF


	#### Which files are to be included in this gem?

	s.files = pkg_files.to_a

	#### Load-time details: library and application (you will need one or both).

    # Use these for libraries.

	s.require_path = 'lib'

	# Use these for applications.

	s.bindir = "bin"
	s.executables = ["jldrill"]
	s.default_executable = "jldrill"
	
	#### Dependencies
    
    s.add_dependency(context_name, "=" + context_version)

    #### Documentation and testing.

	s.has_rdoc = true
	s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
	s.rdoc_options = rd.options

    #### Author and project details.

	s.author = "Mike Charlton"
	s.email = "mikekchar@gmail.com"
	s.homepage = "http://sakabatou.dnsdojo.org"
    s.rubyforge_project = rubyforge_project
end

package_task = Rake::GemPackageTask.new(gem_spec) do |pkg|
	pkg.need_zip = false
	pkg.need_tar = false
end

task :clean_web do
    sh "rm -rf webgen.cache"
    sh "rm -rf web/output"
    sh "rm -rf web/webgen.cache"
end

webgen_task = Webgen::WebgenTask.new('web') do |site|
    site.clobber_outdir = true
    site.config_block = lambda do |config|
        config['sources'] = [['/', "Webgen::Source::FileSystem", 'web/src']]
        config['output'] = ['Webgen::Output::FileSystem', 'web/output']
    end
end

task :publish => [:clean_web, :web] do
    sh "scp web/output/*.html web/output/*.css " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project
    sh "scp web/output/images/* " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project + "/images/"
end

task :clean_debian do
    sh "rm -rf debian/jldrill"
    sh "rm -rf debian/*debhelper*"
    sh "rm -rf debian/files"
    sh "rm -rf configure-stamp"
    sh "rm -rf build-stamp"
end

task :clean => [:clean_web, :clean_debian] do
    sh "rm -rf #{release_dir}"
    sh "rm -rf test_results.html"
    sh "rm -rf doc"
    sh "rm -rf coverage"
    sh "rm -rf pkg"
end

task :release => [:clean, :rcov, :rdoc, :web, :package] do
    mkdir release_dir
    sh "cd #{context_directory}; rake rcov; rake rdoc; rake package"
    sh "cp #{context_directory}/pkg/context-#{context_version}.gem #{release_dir}"
    sh "cp pkg/jldrill-#{JLDrill::VERSION}.gem #{release_dir}"
    sh "cp data/jldrill/fonts/*.ttf #{release_dir}"
end

task :update => [:release]

task :debian_dir => [:clean_debian, :clean_web, :web] do
    # Create the new directory structure
    sh "mkdir debian/jldrill"
    sh "mkdir debian/jldrill/usr"
    sh "mkdir debian/jldrill/usr/bin"
    sh "mkdir debian/jldrill/usr/lib"
    sh "mkdir debian/jldrill/usr/lib/ruby"
    sh "mkdir debian/jldrill/usr/lib/ruby/1.8"    
    sh "mkdir debian/jldrill/usr/share"
    sh "mkdir debian/jldrill/usr/share/jldrill"
    sh "mkdir debian/jldrill/usr/share/applications"
    sh "mkdir debian/jldrill/usr/share/app-install"
    sh "mkdir debian/jldrill/usr/share/app-install/icons"
    sh "mkdir debian/jldrill/usr/share/app-install/desktop"
    sh "mkdir debian/jldrill/usr/share/doc"
    sh "mkdir debian/jldrill/usr/share/doc/jldrill"
    sh "mkdir debian/jldrill/usr/share/doc/jldrill/html"    
    
    # Copy the jldrill source files
    sh "cp -R bin/* debian/jldrill/usr/bin"
    sh "cp -R lib/* debian/jldrill/usr/lib/ruby/1.8"

    # Copy the jldrill data files
    sh "cp -R data/jldrill/COPYING debian/jldrill/usr/share/jldrill"
    sh "cp -R data/jldrill/quiz debian/jldrill/usr/share/jldrill"
    sh "mkdir debian/jldrill/usr/share/jldrill/dict"
    sh "cp -R data/jldrill/dict/Kana debian/jldrill/usr/share/jldrill/dict"
    sh "cp -R data/jldrill/dict/rikaichan debian/jldrill/usr/share/jldrill/dict"
    sh "cp -R data/jldrill/icon.* debian/jldrill/usr/share/jldrill"

    # Copy the desktop and icon files
    sh "cp -R data/jldrill/jldrill.desktop debian/jldrill/usr/share/applications"
    sh "cp -R data/jldrill/jldrill.desktop debian/jldrill/usr/share/app-install/desktop"
    sh "cp -R data/jldrill/icon.svg debian/jldrill/usr/share/app-install/icons/jldrill-icon.svg"

    # Copy the manual
    sh "cp -R web/output/* debian/jldrill/usr/share/doc/jldrill/html"

    # Overwrite the Config file with the Debian version.
    sh "cp config/DebianConfig.rb debian/jldrill/usr/lib/ruby/1.8/jldrill/model/Config.rb"
end

task :deb => [:clean_debian] do
    sh "dpkg-buildpackage -rfakeroot -i.bzr"
end
