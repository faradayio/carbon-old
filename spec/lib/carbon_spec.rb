require 'spec_helper'
require 'active_support/json/encoding'
require 'fakeweb'

CALLBACK_URL = 'http://www.postbin.org/1dj0146'
KEY = 'valid'
EXISTING_UNIQUE_ID = 'oisjoaioijodijaosijdoias'
MISSING_UNIQUE_ID = 'd09joijdoijaloijdoais'
OTHER_UNIQUE_ID = '1092fjoid;oijsao;ga'

FakeWeb.register_uri  :post,
                      /carbon.brighterplanet.com.automobiles/,
                      :status => ["200", "OK"],
                      :body => {
                        'emission' => '134.599',
                        'emission_units' => 'kilograms',
                        'methodology' => 'http://carbon.brighterplanet.com/something',
                        'active_subtimeframe' => Timeframe.new(:year => 2008)
                      }.to_json
#
FakeWeb.register_uri  :post,
                      /carbon.brighterplanet.com.factories/,
                      :status => ["200", "OK"],
                      :body => {
                        'emission' => 1000.0,
                        'emission_units' => 'kilograms',
                        'methodology' => 'http://carbon.brighterplanet.com/something',
                        'active_subtimeframe' => Timeframe.new(:year => 2008)
                      }.to_json
#
FakeWeb.register_uri  :post,
                      /queue.amazonaws.com/,
                      :status => ["200", "OK"],
                      :body => 'You would see an amazon aws response'
# yep, it's stored!
FakeWeb.register_uri  :get,
                      "http://storage.carbon.brighterplanet.com/#{Digest::SHA1.hexdigest(KEY+EXISTING_UNIQUE_ID)}",
                      :status => ["200", "OK"],
                      :body => {
                        'emission' => 1234,
                        'emission_units' => 'kilograms',
                        'methodology' => 'http://carbon.brighterplanet.com/something',
                        'updated_at' => Time.now.as_json
                      }.to_json
#
FakeWeb.register_uri  :get,
                      "http://storage.carbon.brighterplanet.com/#{Digest::SHA1.hexdigest(KEY+OTHER_UNIQUE_ID)}",
                      :status => ["200", "OK"],
                      :body => {
                        'emission' => 99982,
                        'emission_units' => 'kilograms',
                        'methodology' => 'http://carbon.brighterplanet.com/something',
                        'updated_at' => Time.now.as_json
                      }.to_json
#
FakeWeb.register_uri  :get,
                      "http://storage.carbon.brighterplanet.com/#{Digest::SHA1.hexdigest(KEY+MISSING_UNIQUE_ID)}",
                      [
                        {
                          :status => ["404", "Not Found"],
                          :body => "It's not here, you better ask carbon for it!"
                        },
                        {
                          :status => ["200", "OK"],
                          :body => {
                            'emission' => 9876,
                            'emission_units' => 'kilograms',
                            'methodology' => 'http://carbon.brighterplanet.com/something',
                            'updated_at' => Time.now.as_json
                          }.to_json
                        }
                      ]
#
# FakeWeb.register_uri  :post,
#                       /carbon.brighterplanet.com.*#{MISSING_UNIQUE_ID}/,
#                       :status => ["302", "Moved Permanently"],
#                       :body => {
#                         'emission' => 9876,
#                         'emission_units' => 'kilograms',
#                         'methodology' => 'http://carbon.brighterplanet.com/something'
#                       }.to_json,
#                       :headers => { 'Location' => "http://storage.carbon.brighterplanet.com/#{Digest::SHA1.hexdigest(KEY+MISSING_UNIQUE_ID)}" }

class RentalCar
  include Carbon
  attr_accessor :model, :model_year, :fuel_economy
  class Make
    attr_accessor :name
    def to_param
      name
    end
  end
  def make
    @make ||= Make.new
  end
  emit_as :automobile do
    provide :make
    provide :model
    provide :model_year
    provide :fuel_economy, :as => :fuel_efficiency
  end
end

class DonutFactory
  include Carbon
  attr_accessor :smokestack_size, :oven_count, :employees
  class Mixer
    attr_accessor :upc
    def to_param
      raise "Use #to_characteristic instead please"
    end
    def to_characteristic
      upc
    end
  end
  def mixer
    @mixer ||= Mixer.new
  end
  emit_as :factory do
    provide :smokestack_size
    provide :oven_count
    provide :employees, :as => :personnel
    provide :mixer, :key => :upc
  end
end

# set up timeouts
module Carbon
  class EmissionEstimate
    attr_accessor :sleep_before_performing
    VALID_OPTIONS.push :sleep_before_performing
    class Response
      def _perform_with_delay
        sleep parent.sleep_before_performing if parent.sleep_before_performing
        _perform_without_delay
      end
      alias_method_chain :_perform, :delay
    end
  end
end

describe Carbon do
  before(:each) do
    Carbon.key = KEY
  end
  
  it 'should be simple to use' do
    c = RentalCar.new
    c.model = 'Acura'
    c.model_year = 2003
    c.fuel_economy = 32
    c.emission_estimate.should == 134.599
    c.emission_estimate.emission_units.should == 'kilograms'
  end
  
  describe 'caching' do
    it "should keep around estimates if the parameters don't change" do
      c = RentalCar.new
      c.model = 'Acura'
      c.model_year = 2003
      c.fuel_economy = 32
      c.emission_estimate.should == 134.599
      first_raw_request = c.emission_estimate.response.raw_request
      c.emission_estimate.should == 134.599
      c.emission_estimate.response.raw_request.object_id.should == first_raw_request.object_id
    end
    
    it "should recalculate if parameters change" do
      c = RentalCar.new
      c.model = 'Acura'
      c.model_year = 2003
      c.fuel_economy = 32
      c.emission_estimate.should == 134.599
      first_raw_request = c.emission_estimate.response.raw_request
      c.model = 'Honda'
      c.emission_estimate.should == 134.599
      c.emission_estimate.response.raw_request.object_id.should_not == first_raw_request.object_id
    end
    
    it "should recalculate if parameters change (though the options hash)" do
      c = RentalCar.new
      c.model = 'Acura'
      c.model_year = 2003
      c.fuel_economy = 32
      c.emission_estimate.should == 134.599
      first_raw_request = c.emission_estimate.response.raw_request
      c.emission_estimate(:timeframe => Timeframe.new(:year => 2009)).should == 134.599
      c.emission_estimate.response.raw_request.object_id.should_not == first_raw_request.object_id
    end
    
    it "should recalculate if the callback changes" do
      c = RentalCar.new
      c.model = 'Acura'
      c.emission_estimate.should == 134.599
      first_raw_request = c.emission_estimate.response.raw_request
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.response.raw_request.object_id.should_not == first_raw_request.object_id
    end
  end
  
  describe 'requests that can be stored (cached) by guid' do
    it 'should find existing unique ids on S3' do
      d = DonutFactory.new
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID).should == 1234
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID).updated_at.should be_instance_of(Time)
    end
    it "should pass through to realtime if unique id isn't found on S3" do
      d = DonutFactory.new
      d.emission_estimate(:guid => MISSING_UNIQUE_ID).should == 1000
      d.emission_estimate(:guid => MISSING_UNIQUE_ID).response.data.keys.should_not include('updated_at')
      d1 = DonutFactory.new
      d1.emission_estimate(:guid => MISSING_UNIQUE_ID).should == 9876
      d1.emission_estimate(:guid => MISSING_UNIQUE_ID).updated_at.should be_instance_of(Time)
    end
    it "should depend on the user to update the guid if they want a new estimate" do
      d = DonutFactory.new
      d.oven_count = 12_000
      str1 = d.emission_estimate(:guid => EXISTING_UNIQUE_ID).methodology
      str1.should equal(d.emission_estimate(:guid => EXISTING_UNIQUE_ID).methodology)
      d.oven_count = 13_000
      str1.should equal(d.emission_estimate(:guid => EXISTING_UNIQUE_ID).methodology)
      str1.should_not equal(d.emission_estimate(:guid => OTHER_UNIQUE_ID).methodology)
    end
    it 'should be deferrable for use in 2-pass reporting systems' do
      d = DonutFactory.new
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID, :defer => true).number.should be_nil
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID, :defer => true).request.url.should =~ /amazonaws/
    end
    it 'should complain if you provide defer but not guid' do
      d = DonutFactory.new
      lambda {
        d.emission_estimate(:defer => true).request.params
      }.should raise_error(ArgumentError, /defer.*guid/i)
    end
    it 'should complain if you provide guid and callback' do
      d = DonutFactory.new
      lambda {
        d.emission_estimate(:defer => true, :callback => 'foobar').request.params
      }.should raise_error(ArgumentError, /callback.*defer/i)
    end
    it 'should send guid along with other parameters when queueing up deferred request' do
      d = DonutFactory.new
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID, :defer => true).request.params[:MessageBody].should =~ /#{EXISTING_UNIQUE_ID.to_query(:guid)}/
    end
  end
  
  describe 'synchronous (realtime) requests' do
    it 'should send simple params' do
      d = DonutFactory.new
      d.oven_count = 12_000
      d.emission_estimate.request.body.should =~ /oven_count=12000/
    end
    
    it 'send complex params' do
      d = DonutFactory.new
      d.mixer.upc = 123
      d.emission_estimate.request.body.should include({:mixer => { :upc => 123 }}.to_query)
    end
  
    it 'should not send attributes that are blank' do
      d = DonutFactory.new
      d.mixer.upc = 123
      d.emission_estimate.request.body.should_not =~ /oven_count/
      d.emission_estimate.request.body.should_not =~ /timeframe/
    end
    
    it 'should send attributes that are false' do
      d = DonutFactory.new
      d.mixer.upc = false
      d.emission_estimate.request.body.should include({:mixer => { :upc => 'false' }}.to_query)
    end
  
    it 'should send the key' do
      d = DonutFactory.new
      d.emission_estimate.request.body.should =~ /key=valid/
    end
    
    it 'should override defaults' do
      d = DonutFactory.new
      key = 'ADifferentOne'
      d.emission_estimate.key.should == KEY
      d.emission_estimate.key = key
      d.emission_estimate.key.should == key
    end
    
    it 'should accept timeouts' do
      d = DonutFactory.new
      lambda {
        d.emission_estimate(:sleep_before_performing => 2, :timeout => 1).to_f
      }.should raise_error(::Timeout::Error)
    end
  
    it 'should accept timeframes' do
      c = RentalCar.new
      t = Timeframe.new(:year => 2009)
      c.emission_estimate.timeframe = t
      c.emission_estimate.request.body.should include(t.to_query(:timeframe))
    end
    
    it 'should accept timeframes inline' do
      c = RentalCar.new
      t = Timeframe.new(:year => 2009)
      c.emission_estimate(:timeframe => t)
      c.emission_estimate.request.body.should include(t.to_query(:timeframe))
    end
    
    it 'should read active subtimeframes back from calculations' do
      c = RentalCar.new
      c.emission_estimate.active_subtimeframe.should == Timeframe.new(:year => 2008)
    end
  
    it 'should not generate post bodies with lots of empty params' do
      c = RentalCar.new
      c.emission_estimate :timeframe => Timeframe.new(:year => 2009)
      c.emission_estimate.request.body.should_not include('&&')
      c.emission_estimate.request.body.should_not =~ /=[^a-z0-9]/i
    end
  end
  
  describe 'asynchronous (queued) requests' do
    it 'should post a message to SQS' do
      c = RentalCar.new
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.request.url.should =~ /queue.amazonaws.com/
    end
    
    it 'should have nil data in its response' do
      c = RentalCar.new
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.number.should be_nil
      c.emission_estimate.emission_units.should be_nil
      c.emission_estimate.methodology.should be_nil
    end
    
    it "should not compare itself to numbers" do
      c = RentalCar.new
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.should_not == 0.0
    end
    
    it 'should not allow itself to be treated as a number' do
      c = RentalCar.new
      c.emission_estimate.callback = CALLBACK_URL
      lambda {
        c.emission_estimate + 5
      }.should raise_error(::Carbon::TriedToUseAsyncResponseAsNumber)
      lambda {
        c.emission_estimate.to_f
      }.should raise_error(::Carbon::TriedToUseAsyncResponseAsNumber)
    end
  end
  
  describe 'internally' do
    it "should ignore invalid options passed to #emission_estimate" do
      c = RentalCar.new
      t = Timeframe.new(:year => 2009)
      c.emission_estimate :timeframe => t, :method_missing => 'helo there', :response => 'foo'
      c.emission_estimate.instance_variable_get(:@timeframe).object_id.should == t.object_id
      c.emission_estimate.instance_variable_get(:@method_missing).should be_nil
      c.emission_estimate.instance_variable_get(:@response).should be_nil
    end
    
    it "should raise an error on EmissionEstimate if method isn't found" do
      c = RentalCar.new
      lambda {
        c.emission_estimate.foobar
      }.should raise_error(NoMethodError, /EmissionEstimate/)
    end
    
    it "should use #to_characteristic instead of #to_param if it's available" do
      d = DonutFactory.new
      lambda {
        d.mixer.to_param
      }.should raise_error(RuntimeError, /instead please/)
      lambda {
        d.emission_estimate.to_f
      }.should_not raise_error
    end
  end
end

# an average car emits 6 tons of carbon in a year
# it 'should actually do a request!' do
#   FakeWeb.clean_registry
#   c = RentalCar.new
#   c.emission_estimate.to_i.should be_close(5500, 500)
#   c.emission_estimate.emission_units.should == 'kilograms'
# end

