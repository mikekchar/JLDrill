require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rubygems'
require 'rake/gempackagetask'
require 'lib/jldrill/Version'

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

spec_files = FileList[
	'spec/**/*_spec.rb',
	'spec/**/*_story.rb'
]

# This just makes sure that spec is looking in the right directories for
# the source.
ruby_opts = ["-KO", "-I./lib"]


task :default => [:rcov, :rdoc]

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
	    "--exclude _spec", "--exclude /lib/Context/", "--exclude _story"]
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


	#### Which files are to be included in this gem?  Everything!

	s.files = pkg_files.to_a

	#### Load-time details: library and application (you will need one or both).

    # Use these for libraries.

	s.require_path = 'lib'

	# Use these for applications.

	s.bindir = "bin"
	s.executables = ["jldrill"]
	s.default_executable = "jldrill"
	
	#### Dependencies
    
    s.add_dependency('context', '>=0.0.1')


    #### Documentation and testing.

	s.has_rdoc = true
	s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
	s.rdoc_options = rd.options

    #### Author and project details.

	s.author = "Mike Charlton"
	s.email = "mikekchar@gmail.com"
	s.homepage = "http://sakabatou.dnsdojo.org"
end

package_task = Rake::GemPackageTask.new(gem_spec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
end

