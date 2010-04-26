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
      stub_rest_client

      rc = RentalCar.new
      rc.model = 'Acura'
      rc.model_year = 2003
      rc.fuel_economy = 32
      rc.emissions.value.should == 134.599
    end
  end
end
