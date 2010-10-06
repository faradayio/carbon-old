require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'carbon'
    gemspec.summary = %q{Carbon is a Ruby API wrapper for the Brighter Planet emission estimate web service (http://carbon.brighterplanet.com).}
    gemspec.description = %q{Carbon is a Ruby API wrapper for the Brighter Planet emission estimate web service (http://carbon.brighterplanet.com). By querying the web service, it can estimate the carbon emissions of many real-life objects, such as cars and houses, based on particular attributes that they may have.}
    gemspec.email = 'derek.kastner@brighterplanet.com'
    gemspec.homepage = 'http://carbon.brighterplanet.com/libraries'
    gemspec.authors = ['Derek Kastner', 'Seamus Abshere', 'Andy Rossmeissl']

    gemspec.required_ruby_version = '~>1.9.1'

    gemspec.add_dependency 'activesupport', '>=2.3.5'
    gemspec.add_dependency 'nap', '>=0.4'
    gemspec.add_dependency 'timeframe', '>=0.0.7'
    # This is still only on Rubyforge
    gemspec.add_dependency 'blockenspiel', '>=0.3.2'
    gemspec.add_dependency 'conversions', '~>1'

    gemspec.add_development_dependency 'fakeweb', '>=1.2.8'
    # sabshere 7/16/10 if you're having trouble running specs, try "rspec spec" and/or "sudo gem install rspec --pre"
    # sabshere 7/20/10 this might not work with activesupport 2
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
  rdoc.title = "carbon #{version}"
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('doc/*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
