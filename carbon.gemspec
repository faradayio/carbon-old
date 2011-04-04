# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "carbon/version"

Gem::Specification.new do |s|
  s.name        = "carbon"
  s.version     = Carbon::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Derek Kastner', 'Seamus Abshere', 'Andy Rossmeissl']
  s.email       = ['derek.kastner@brighterplanet.com']
  s.homepage    = 'https://github.com/brighterplanet/carbon'
  s.summary     = %q{Carbon is a Ruby API wrapper for the Brighter Planet emission estimate web service (http://carbon.brighterplanet.com).}
  s.description = %q{Carbon is a Ruby API wrapper for the Brighter Planet emission estimate web service (http://carbon.brighterplanet.com). By querying the web service, it can estimate the carbon emissions of many real-life objects, such as cars and houses, based on particular attributes that they may have.}

  s.rubyforge_project = "carbon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'activesupport', '>=2.3.5'
  s.add_dependency 'i18n' # activesupport?
  s.add_dependency 'nap'
  s.add_dependency 'timeframe'
  s.add_dependency 'blockenspiel'
  s.add_dependency 'conversions'
  s.add_dependency 'brighter_planet_metadata'
  s.add_dependency 'bombshell'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'aruba'
end
