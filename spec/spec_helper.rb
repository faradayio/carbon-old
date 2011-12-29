require 'bundler'
Bundler.setup
$:.unshift File.expand_path('../../lib', __FILE__)

require 'fakeweb'
require 'carbon'

Dir.glob(File.expand_path('../support/**/*.rb', __FILE__)).each do |s|
  require s
end

RSpec.configure do |config|
  config.before(:all) do
    Carbon.key = 'ABC123'
    Carbon.log = Logger.new nil
  end
end

require 'vcr'
VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.stub_with :fakeweb
end
