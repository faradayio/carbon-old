require 'fakeweb'

def stub_rest_client
  response = { 
    'emission' => 134.599,
    'methodology' => 'http://carbon.brighterplanet.com/something' }
  FakeWeb.register_uri(:post, /.*/, :body => response.to_json)
end
