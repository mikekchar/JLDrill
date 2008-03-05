require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'rake/testtask'


files = FileList['lib/jldrill/*_spec.rb','lib/jldrill/Gtk/*_spec.rb']
# This just makes sure that spec is looking in the right directories for
# the source.
ruby_opts = ["-KO", "-I./lib/jldrill"]


task :default => [:rcov, :rdoc]

# Run the rspec tests
Spec::Rake::SpecTask.new(:spec) do |t|
	t.spec_files = files
	t.ruby_opts = ruby_opts
end

# Run the rspec tests with the code coverage program rcov
Spec::Rake::SpecTask.new(:rcov) do |t|
	t.spec_files = files
	t.rcov = true
	t.rcov_opts = ["--exclude rspec", "--exclude rcov", "--exclude syntax"]
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
Rake::RDocTask.new(:rdoc) do |t|
	t.rdoc_dir = 'doc'
#  t.template = 'kilmer'
#  t.template = 'css2'
	t.title    = "JLDrill -- Japanese Language Drill program"
	t.options << '--inline-source' <<
		'--main' << 'README' <<
		'--title' <<  'JLDrill -- Japanese Language Drill program' 
	t.rdoc_files.include('README', 'COPYING', 'THANKS', 'data/jldrill/COPYING')
	t.rdoc_files.include('lib/**/*.rb')
end

