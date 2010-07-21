require 'rubygems'
require 'rspec'
begin
  require 'ruby-debug'
rescue
end

require 'active_support/json/encoding'

require 'carbon'

require 'fakeweb'
[
  [ /http:\/\/carbon.brighterplanet.com\/automobiles/, {
    'emission' => '134.599',
    'emission_units' => 'kilograms',
    'methodology' => 'http://carbon.brighterplanet.com/something',
    'active_subtimeframe' => Timeframe.new(:year => 2008)
  }.to_json],
  [ /http:\/\/carbon.brighterplanet.com\/factories/, {
    'emission' => 1000.0,
    'emission_units' => 'kilograms',
    'methodology' => 'http://carbon.brighterplanet.com/something'
  }.to_json],
  [ /https:\/\/queue.amazonaws.com/,
    'Nothing to see here.']
].each do |url_matcher, response|
  FakeWeb.register_uri :post, url_matcher, :body => response
end

