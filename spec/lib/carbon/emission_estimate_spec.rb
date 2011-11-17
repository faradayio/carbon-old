require 'spec_helper'
require 'uri'

describe Carbon::EmissionEstimate do
  describe '.parse' do
    it 'parses a standard CM1 response' do
      response = nil
      VCR.use_cassette('flight', :record => :once) do
        response = Net::HTTP.post_form(URI('http://carbon.brighterplanet.com/flights.json'), {})
      end
      estimate = Carbon::EmissionEstimate.parse response.body
      estimate['emission'].should > 0
    end
    it 'parses a CM1 response with an active_subtimeframe' do
      response = nil
      VCR.use_cassette('residence', :record => :once) do
        response = Net::HTTP.post_form(URI('http://carbon.brighterplanet.com/residences.json'), {})
      end
      estimate = Carbon::EmissionEstimate.parse response.body
      estimate['active_subtimeframe'].should be_a(Timeframe)
    end
  end

  describe '#take_options' do
    it 'accepts the :comply option' do
      estimate = Carbon::EmissionEstimate.new(RentalCar.new)
      estimate.take_options :comply => :iso
      estimate.comply.should == :iso
    end
  end
end

