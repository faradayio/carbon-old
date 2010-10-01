# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{carbon}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Derek Kastner", "Seamus Abshere", "Andy Rossmeissl"]
  s.date = %q{2010-10-01}
  s.default_executable = %q{carbon}
  s.description = %q{Carbon is a Ruby API wrapper for the Brighter Planet emission estimate web service (http://carbon.brighterplanet.com). By querying the web service, it can estimate the carbon emissions of many real-life objects, such as cars and houses, based on particular attributes that they may have.}
  s.email = %q{derek.kastner@brighterplanet.com}
  s.executables = ["carbon"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/carbon",
     "carbon.gemspec",
     "doc/INTEGRATION_GUIDE.rdoc",
     "doc/examining-response-with-jsonview.png",
     "doc/shell_example",
     "doc/timeout-error.png",
     "doc/with-committee-reports.png",
     "doc/without-committee-reports.png",
     "lib/carbon.rb",
     "lib/carbon/base.rb",
     "lib/carbon/cli.rb",
     "lib/carbon/cli/emitter.rb",
     "lib/carbon/cli/environment.rb",
     "lib/carbon/cli/irb.rb",
     "lib/carbon/cli/shell.rb",
     "lib/carbon/emission_estimate.rb",
     "lib/carbon/emission_estimate/request.rb",
     "lib/carbon/emission_estimate/response.rb",
     "lib/carbon/emission_estimate/storage.rb",
     "spec/lib/carbon/emission_estimate/response_spec.rb",
     "spec/lib/carbon_spec.rb",
     "spec/spec_helper.rb",
     "spec/specwatchr"
  ]
  s.homepage = %q{http://carbon.brighterplanet.com/libraries}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Carbon is a Ruby API wrapper for the Brighter Planet emission estimate web service (http://carbon.brighterplanet.com).}
  s.test_files = [
    "spec/lib/carbon/emission_estimate/response_spec.rb",
     "spec/lib/carbon_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_runtime_dependency(%q<nap>, [">= 0.4"])
      s.add_runtime_dependency(%q<timeframe>, [">= 0.0.7"])
      s.add_runtime_dependency(%q<SystemTimer>, [">= 1.2"])
      s.add_runtime_dependency(%q<blockenspiel>, [">= 0.3.2"])
      s.add_runtime_dependency(%q<conversions>, ["~> 1"])
      s.add_development_dependency(%q<fakeweb>, [">= 1.2.8"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta.17"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_dependency(%q<nap>, [">= 0.4"])
      s.add_dependency(%q<timeframe>, [">= 0.0.7"])
      s.add_dependency(%q<SystemTimer>, [">= 1.2"])
      s.add_dependency(%q<blockenspiel>, [">= 0.3.2"])
      s.add_dependency(%q<conversions>, ["~> 1"])
      s.add_dependency(%q<fakeweb>, [">= 1.2.8"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta.17"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    s.add_dependency(%q<nap>, [">= 0.4"])
    s.add_dependency(%q<timeframe>, [">= 0.0.7"])
    s.add_dependency(%q<SystemTimer>, [">= 1.2"])
    s.add_dependency(%q<blockenspiel>, [">= 0.3.2"])
    s.add_dependency(%q<conversions>, ["~> 1"])
    s.add_dependency(%q<fakeweb>, [">= 1.2.8"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta.17"])
  end
end

