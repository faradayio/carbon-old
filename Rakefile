require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new('examples') do |c|
  c.rspec_opts = '-Ispec'
end

task :default => :examples

desc "Run specs with RCov"
RSpec::Core::RakeTask.new(:examples_with_coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
  t.rspec_opts = '-Ispec'
end

require 'rake'
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'carbon'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
