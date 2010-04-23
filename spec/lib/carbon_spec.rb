require 'spec_helper'

describe Carbon do
  describe '.api_key' do
    it 'should store the API key' do
      Carbon.api_key = 'abc123'
      Carbon.api_key.should == 'abc123'
    end
  end

  describe '.base_url' do
    it 'should store the service base URL' do
      Carbon.base_url.should == 'http://carbon.brighterplanet.com'
    end
  end

  describe 'usage' do
    it 'should be simple' do
      pending "Andy's ideas"
      flight = Carbon::Flight.new
      flight.airports = ['DTW','MSP','SFO']
    end
    it 'should return the typical american footprint for an activity' do
      pending "Andy's ideas"
      typical = Carbon::Diet.new
      typical.calculate!
      typical.footprint.should be_a_kind_of(Numeric)
    end
    it 'should use a dsl' do
      pending "Andy's ideas"
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
      pending "Andy's ideas"
      airports = Carbon::FlightOption::Airport.all
      detroit = Carbon::FlightOption::Airport.find(:city => 'Detroit')
      seattle = Carbon::FlightOption::Airport.find_all(:city => 'Seattle')
      flight = Carbon::Flight.new(:to => seattle, :from => detroit)
    end
  end
end
