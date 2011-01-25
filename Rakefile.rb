require 'rake'
gem 'rspec', "= 1.3.1"
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
context_version = "0.0.22"
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
spec_opts = ['-f html:test_results.html -f profile:profile.txt']
spec_files = FileList[
	'spec/**/*_spec.rb',
	'spec/**/*_story.rb'
]

# Options for running the application
ruby_opts = ["-KO", "-I./lib", "-rrubygems"]

task :default => [:spec]

desc "Run the tests (default).  Output goes to test_results.html"
Spec::Rake::SpecTask.new(:spec) do |t, args|
	t.spec_files = spec_files
	t.ruby_opts = ruby_opts
    t.spec_opts = spec_opts
end

desc "Run the tests and find the code coverage.  Test results are in test_results.html.  Coverage is in coverage/index.html"
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

desc "Runs rcov but excludes the source files instead of the test files.  This is how I determine how many lines of test code I have.  Note, this crashes writing out the file coverage for some reason.  It seems to be a bug in rcov.  But since I'm only interested in the file sizes, I don't care.  Output goes to coverage/index.html"
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
	s.version = JLDrill::VERSION
	s.summary = "Japanese Language Drill Program"
	s.description = <<-EOF
        JLDrill is a program for helping people drill aspects of the
        Japanese language using spaced repetition.  It features a
        dictionary cross reference tool, a pop-up kanji/vocabulary reference
        (inspired by rikaichan for Firefox), and the ability to
        import EDICT format files (EUC or UTF8 encoded).  Included
        drills: kana, JLPT, and grammar.
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
    
    s.add_dependency("gtk2")
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

desc "Creates the gem files for jldrill.  Packages are placed in pkg and called jldrill-<version>.gem."
package_task = Rake::GemPackageTask.new(gem_spec) do |pkg|
	pkg.need_zip = false
	pkg.need_tar = false
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

desc "Build the web page and upload it to Rubyforge."
task :publish => [:clean_web, :web] do
    sh "scp web/output/*.html web/output/*.css " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project
    sh "scp web/output/images/* " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project + "/images/"
end

desc "Cleans the debian tree."
task :clean_debian do
    FileUtils.rm_rf('debian/jldrill')
    FileUtils.rm_rf(Dir.glob('debian/*debhelper*'))
    FileUtils.rm_rf('debian/files')
    FileUtils.rm_rf('configure-stamp')
    FileUtils.rm_rf('build-stamp')
end

desc "Cleans everything for a pristine source directory."
task :clean => [:clobber_package, :clobber_rcov, :clobber_rdoc, 
                :clobber_web, :clean_debian] do
    FileUtils.rm_rf release_dir
end

desc "Create the debian source tree and copy the required files over.  The files will end up in debian/jldrill"
task :debian_dir => [:clean_debian, :clean_web, :web] do
    # Create the new directory structure
    FileUtils.mkdir_p "debian/jldrill/usr/bin"
    FileUtils.mkdir_p "debian/jldrill/usr/lib/ruby/1.8"
    FileUtils.mkdir_p "debian/jldrill/usr/share/jldrill/dict"
    FileUtils.mkdir_p "debian/jldrill/usr/share/applications"
    FileUtils.mkdir_p "debian/jldrill/usr/share/app-install/icons"
    FileUtils.mkdir_p "debian/jldrill/usr/share/app-install/desktop"
    FileUtils.mkdir_p "debian/jldrill/usr/share/doc/jldrill/html"
	FileUtils.mkdir_p "debian/jldrill/usr/share/jldrill/Tanaka"
    
    # Copy the jldrill source files
    FileUtils.cp_r Dir.glob("bin/*"), "debian/jldrill/usr/bin"
    FileUtils.cp_r Dir.glob("lib/*"), "debian/jldrill/usr/lib/ruby/1.8"

    # Copy the jldrill data files
    FileUtils.cp_r "data/jldrill/COPYING", "debian/jldrill/usr/share/jldrill"
    FileUtils.cp_r "data/jldrill/quiz", "debian/jldrill/usr/share/jldrill"
    FileUtils.cp_r "data/jldrill/dict/Kana", "debian/jldrill/usr/share/jldrill/dict"
    FileUtils.cp_r "data/jldrill/dict/rikaichan", "debian/jldrill/usr/share/jldrill/dict"
    FileUtils.cp_r Dir.glob("data/jldrill/icon.*"), "debian/jldrill/usr/share/jldrill"
	FileUtils.cp_r "data/jldrill/Tanaka/examples.utf", "debian/jldrill/usr/share/jldrill/Tanaka"

    # Copy the desktop and icon files
    FileUtils.cp_r "data/jldrill/jldrill.desktop", "debian/jldrill/usr/share/applications"
    FileUtils.cp_r "data/jldrill/jldrill.desktop", "debian/jldrill/usr/share/app-install/desktop"
    FileUtils.cp_r "data/jldrill/icon.svg", "debian/jldrill/usr/share/app-install/icons/jldrill-icon.svg"

    # Copy the manual
    FileUtils.cp_r Dir.glob("web/output/*"), "debian/jldrill/usr/share/doc/jldrill/html"

    # Overwrite the Config file with the Debian version.
    FileUtils.cp_r "config/DebianConfig.rb",  "debian/jldrill/usr/lib/ruby/1.8/jldrill/model/Config.rb"
end

desc "Build a debian package. Note: This will *not* make a source package.  Also, the .deb and .changes file will be put in the parent directory."
task :deb => [:clean_debian] do
    sh "dpkg-buildpackage -b -tc -rfakeroot -i.bzr"
end

desc "Build target for the Context lib"
task :build_context do
    sh "cd #{context_directory}; rake build"
end

desc "Create gem packages for the Context lib"
task :package_context do
    sh "cd #{context_directory}; rake package"
end

desc "Create deb files for the Context lib"
task :deb_context do
    sh "cd #{context_directory}; rake deb"
end

desc "Clean everything, build context, run tests, and build all the documentation."
task :build => [:clean, :build_context, :rcov, :rdoc, :web]

desc "Build everything and create both the Context and JLDrill gems."
task :gems => [:build, :package_context, :package]

desc "Build both the Context and JLDrill deb files."
task :debs => [:deb_context, :deb]

desc "Rebuild everything, create gems and debs for Context and JLDrill, place all distributable files in the jldrill-<version> directory.  Used for creating a new release of JLDrill.  Note: it does not publish the web page."
task :release => [:build, :debs, :gems] do
    FileUtils.mkdir release_dir
    FileUtils.cp "#{context_directory}/pkg/context-#{context_version}.gem", release_dir
    FileUtils.cp "pkg/jldrill-#{JLDrill::VERSION}.gem", release_dir
    FileUtils.cp Dir.glob("data/jldrill/fonts/*.ttf"), release_dir
    FileUtils.mv Dir.glob("../libcontext-ruby_#{context_version}-*.*"), release_dir
    FileUtils.mv Dir.glob("../jldrill_#{JLDrill::VERSION}-*.*"), release_dir
end

desc "Alias for release.  Run this after doing a bzr update so that everything is rebuilt."
task :update => [:release]
