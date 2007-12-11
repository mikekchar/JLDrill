require 'rake'
require 'spec/rake/spectask'

files = FileList['lib/jldrill/*_spec.rb','lib/jldrill/Gtk/*_spec.rb']
# This just makes sure that spec is looking in the right directories for
# the source.
ruby_opts = ["-I./lib/jldrill"]


task :default => [:rcov]

Spec::Rake::SpecTask.new(:spec) do |t|
	t.spec_files = files
	t.ruby_opts = ruby_opts
end

Spec::Rake::SpecTask.new(:rcov) do |t|
	t.spec_files = files
	t.rcov = true
	t.rcov_opts = ["--exclude rspec", "--exclude rcov", "--exclude syntax"]
	t.spec_opts = ["--format html:test_results.html"]
	t.ruby_opts = ruby_opts
end

Spec::Rake::SpecTask.new(:heckle) do |t|
	t.spec_files = files
	t.spec_opts = ["--heckle Anjin"]
	t.ruby_opts = ruby_opts
end

