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
      class RentalCar
        include Carbon::Emitter

        attr_accessor :model, :model_year, :fuel_economy

        emits_as :automobile do
          provides :model
          provides :model_year
          provides :fuel_efficiency, :as => :fuel_economy
        end
      end

      rc = RentalCar.new
      rc.model = 'Acura'
      rc.model_year = 2003
      rc.fuel_economy = 32
      rc.emissions.value.should == 184
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
