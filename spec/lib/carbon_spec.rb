require 'spec_helper'

CALLBACK_URL = 'http://www.postbin.org/1dj0146'

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

describe Carbon do
  before(:each) do
    Carbon.key = 'valid'
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
      d.emission_estimate.key.should == 'valid'
      d.emission_estimate.key = key
      d.emission_estimate.key.should == key
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
      c.emission_estimate.emission_value.should be_nil
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

