require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rubygems'
require 'rake/gempackagetask'
require 'webgen/webgentask'
require 'lib/jldrill/Version'

rubyforge_project = "jldrill"
rubyforge_maintainer = "mikekchar@rubyforge.org"

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

spec_files = FileList[
	'spec/**/*_spec.rb',
	'spec/**/*_story.rb'
]

# This just makes sure that spec is looking in the right directories for
# the source.
ruby_opts = ["-KO", "-I./lib"]


# task :default => [:rcov, :rdoc]
task :default => [:spec]

# Run the rspec tests
Spec::Rake::SpecTask.new(:spec) do |t|
	t.spec_files = spec_files
	t.ruby_opts = ruby_opts
end

# Run the rspec tests with the code coverage program rcov
Spec::Rake::SpecTask.new(:rcov) do |t|
	t.spec_files = spec_files
	t.rcov = true
	t.rcov_opts = ["--exclude rspec", "--exclude rcov", "--exclude syntax",
	    "--exclude _spec", "--exclude /lib/Context/", "--exclude _story",
	    "--exclude cairo", "--exclude pango", "--exclude gtk2", "--exclude atk",
	    "--exclude glib", "--exclude gdk"]
	t.spec_opts = ["--format html:test_results.html"]
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
	t.rdoc_files.include('README', 'COPYING', 'THANKS', 'data/jldrill/COPYING')
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
	    JLDrill is a Japanese Language Drill program.  It is meant to help
	    you learn Japanese through drills.  It also has a rudimentary
	    dictionary (with no lookup yet).
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
    
    s.add_dependency('context', '>=0.0.16')

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
	pkg.need_zip = true
	pkg.need_tar = true
end

webgen_task = Webgen::WebgenTask.new('web') do |site|
    site.clobber_outdir = true
    site.config_block = lambda do |config|
        config['sources'] = [['/', "Webgen::Source::FileSystem", 'web/src']]
        config['output'] = ['Webgen::Output::FileSystem', 'web/output']
    end
end

task :publish => [:web] do
    sh "scp web/output/*.html web/output/*.css " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project
    sh "scp web/output/images/* " + rubyforge_maintainer + ":/var/www/gforge-projects/" + rubyforge_project + "/images/"
end


