require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'carbon'
    gemspec.summary = %q{A gem for calculating carbon footprints using Brighter Planet's Carbon Middleware service}
    gemspec.description = %q{Carbon allows you to easily calculate the carbon footprint of various activities. This is an API for the Brighter Planet Carbon Middleware service.}
    gemspec.email = 'derek.kastner@brighterplanet.com'
    gemspec.homepage = 'http://carbon.brighterplanet.com/libraries'
    gemspec.authors = ['Derek Kastner', 'Seamus Abshere']
    gemspec.add_dependency 'activesupport', '>=2.3.5'
    gemspec.add_dependency 'httparty', '>=0.6.0'

    gemspec.add_development_dependency 'fakeweb', '>=1.2.8'
    # sabshere 7/16/10 if you're having trouble running specs, try "rspec spec" and/or "sudo gem install rspec --pre"
    gemspec.add_development_dependency 'rspec', '>=2.0.0.beta.17'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "decider #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
