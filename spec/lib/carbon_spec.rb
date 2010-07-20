require 'spec_helper'

class RentalCar
  include Carbon
  attr_accessor :make, :model, :model_year, :fuel_economy
  emit_as :automobile do
    provide :make
    provide :model
    provide :model_year
    provide :fuel_efficiency, :as => :fuel_economy
  end
end

class DonutFactory
  include Carbon
  attr_accessor :smokestack_size, :oven_count, :mixer_size, :mixer_wattage, :employees
  emit_as :factory do
    provide :smokestack_size
    provide :oven_count
    provide :size, :of => :mixer
    provide :wattage, :of => :mixer
    provide :personnel, :as => :employees
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
    e = c.emission
    e.should == 134.599
    e.emission_units.should == 'kilograms'
  end
  
  describe 'synchronous (realtime) requests' do
    before(:each) do
      Carbon.mode = :realtime
    end
    
    it 'should handle complex attributes like mixer[size]' do
      d = DonutFactory.new
      d.mixer_size = 20
      d._carbon_request_body.should =~ /mixer\[size\]=20/
    end
  
    it 'should not send attributes that are blank' do
      d = DonutFactory.new
      d.mixer_size = 20
      d._carbon_request_body.should_not =~ /oven_count/
    end
  
    it 'should send the key' do
      d = DonutFactory.new
      d._carbon_request_body.should =~ /key=valid/
    end
    
    it 'should override defaults' do
      d = DonutFactory.new
      d.emission(:key => 'ADifferentOne')
      d.last_carbon_request.body.should =~ /key=ADifferentOne/
    end
  
    it 'should accept timeframes' do
      c = RentalCar.new
      c.emission :timeframe => Timeframe.new(:year => 2009)
      c.last_carbon_request.body.should =~ /timeframe=2009-01-01%2F2010-01-01/
    end
  
    it 'should not generate post bodies with lots of empty params' do
      c = RentalCar.new
      c.emission :timeframe => Timeframe.new(:year => 2009)
      c.last_carbon_request.body.should_not include('&&')
    end
  end
  
  describe 'asynchronous (queued) requests' do
    before(:each) do
      Carbon.mode = :async
    end
    
    it 'should raise an exception if no callback is provided' do
      c = RentalCar.new
      lambda {
        c.emission :timeframe => Timeframe.new(:year => 2009)
      }.should raise_error(Carbon::BlankCallback)
    end
    
    it 'should post a message to SQS' do
      c = RentalCar.new
      c._carbon_request_url.should =~ /queue.amazonaws.com/
      c.emission :timeframe => Timeframe.new(:year => 2009), :callback => 'http://www.postbin.org/1dj0145'
    end
  end
end

# an average car emits 6 tons of carbon in a year
# it 'should actually do a request!' do
#   FakeWeb.clean_registry
#   c = RentalCar.new
#   c.emission.to_i.should be_close(5500, 500)
#   c.emission.emission_units.should == 'kilograms'
# end

