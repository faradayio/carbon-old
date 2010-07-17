require 'fakeweb'

POSSIBLE_RESPONSES = {
  :rental_car => {
    'emission' => '134.599',
    'emission_units' => 'kilograms',
    'methodology' => 'http://carbon.brighterplanet.com/something'
  },
  :donut_factory => {
    'emission' => 1000.0,
    'emission_units' => 'kilograms',
    'methodology' => 'http://carbon.brighterplanet.com/something'
  }
}

# sabshere 7/16/10 shouldn't we use a real matcher like /.*\/#{name.to_s.pluralize}.*/ ?
def stub_http(name)
  FakeWeb.register_uri :post, /.*/, :body => POSSIBLE_RESPONSES[name].to_json
end
