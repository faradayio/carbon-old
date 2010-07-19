require 'spec_helper'

class RentalCar
  include Carbon
  attr_accessor :model, :model_year, :fuel_economy
  emit_as :automobile do
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
  after(:each) do
    Carbon.key = 'valid'
    Carbon.base_url = Carbon::DEFAULT_BASE_URL
  end
  
  it 'should be simple to use' do
    stub_http :rental_car
    c = RentalCar.new
    c.model = 'Acura'
    c.model_year = 2003
    c.fuel_economy = 32
    c.emission.should == 134.599
    c.emission.emission_units.should == 'kilograms'
  end
  
  describe 'synchronous (realtime) requests' do
    it 'should handle complex attributes like mixer[size]' do
      stub_http :donut_factory
      d = DonutFactory.new
      d.mixer_size = 20
      d._carbon_request_body.should =~ /mixer\[size\]=20/
      d.emission.should == 1000
    end
  
    it 'should not send attributes that are blank' do
      stub_http :donut_factory
      d = DonutFactory.new
      d.mixer_size = 20
      d._carbon_request_body.should_not =~ /oven_count/
      d.emission.should == 1000
    end
  
    it 'should send the key' do
      d = DonutFactory.new
      d._carbon_request_body.should =~ /key=valid/
    end
  
    it 'should accept timeframes' do
      c = RentalCar.new
      c._carbon_request_body(:timeframe => Timeframe.new(:year => 2009)).should =~ /timeframe=2009-01-01%2F2010-01-01/
    end
  
    it 'should not generate post bodies with lots of empty params' do
      c = RentalCar.new
      c._carbon_request_body(:timeframe => Timeframe.new(:year => 2009)).should_not include('&&')    
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

