Gem::Specification.new do |s|
  s.name = 'carbon'
  s.version = "0.0.10"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Derek Kastner"]
  s.date = '2010-04-30'
  s.summary = %q{A gem for calculating carbon footprints using Brighter Planet's Carbon Middleware service}
  s.description = %q{Carbon allows you to easily calculate the carbon footprint of various activities. This is an API for the Brighter Planet Carbon Middleware service.}
  s.email = 'derek@brighterplanet.com'
  s.extra_rdoc_files = [
    "MIT-LICENSE.txt",
  ]
  s.files = Dir.glob('lib/**/*') 

  s.add_runtime_dependency('activesupport')
  s.add_runtime_dependency('httparty')
  s.add_development_dependency('fakeweb')
  s.add_development_dependency('rspec')
end
