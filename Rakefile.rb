require 'rake'
require 'spec/rake/spectask'

files = FileList['*_spec.rb','Gtk/*_spec.rb']

task :default => [:rcov]

Spec::Rake::SpecTask.new(:spec) do |t|
	t.spec_files = files
end

Spec::Rake::SpecTask.new(:rcov) do |t|
	t.spec_files = files
	t.rcov = true
	t.rcov_opts = ["--exclude rspec", "--exclude rcov", "--exclude syntax"]
	t.spec_opts = ["--format html:test_results.html"]
end

Spec::Rake::SpecTask.new(:heckle) do |t|
	t.spec_files = files
	t.spec_opts = ["--heckle Anjin"]
end

