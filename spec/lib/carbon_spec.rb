require 'spec_helper'

describe Carbon do
  describe '.api_key' do
    it 'should store the API key' do
      Carbon.api_key = 'abc123'
      Carbon.api_key.should == 'abc123'
    end
  end

  describe 'usage' do
    it 'should be simple' do
      flight = Carbon::Flight.new
      flight.airports = ['DTW','MSP','SFO']
    end
    it 'should return the typical american footprint for an activity' do
      typical = Carbon::Diet.new
      typical.calculate!
      typical.footprint.should be_a_kind_of(Numeric)
    end
    it 'should use a dsl' do
      include Carbon::DSL

      my_flight = flight do
        start 'DTW'
        stop 'MSP'
        plane 'Boeing 767'
      end

      my_trip = trip do
        flight do
          start city('Amsterdam')
        end
        drive
        train do
          start 'LNS'
          stop 'CHI'
        end
      end
      my_trip.footprint.should be_a_kind_of(Numeric)
    end
    it 'should allow me to fetch valid airport codes' do
      airports = Carbon::FlightOption::Airport.all
      detroit = Carbon::FlightOption::Airport.find(:city => 'Detroit')
      seattle = Carbon::FlightOption::Airport.find_all(:city => 'Seattle')
      flight = Carbon::Flight.new(:to => seattle, :from => detroit)
    end
  end
end
