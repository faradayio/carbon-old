require 'rubygems'
require 'rspec'
begin
  require 'ruby-debug'
rescue
end

require 'carbon'

require 'fakeweb'
{
  'automobiles' => {
    'emission' => '134.599',
    'emission_units' => 'kilograms',
    'methodology' => 'http://carbon.brighterplanet.com/something'
  },
  'factories' => {
    'emission' => 1000.0,
    'emission_units' => 'kilograms',
    'methodology' => 'http://carbon.brighterplanet.com/something'
  }
}.each do |k, v|
  FakeWeb.register_uri :post, /#{k}/, :body => v.to_json
end