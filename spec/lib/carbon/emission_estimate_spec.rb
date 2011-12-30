require 'spec_helper'
require 'uri'

describe Carbon::EmissionEstimate do
  CALLBACK_URL = 'http://www.postbin.org/1dj0146'

  let(:rental_car) { RentalCar.new }
  let(:rental_car_estimate) { Carbon::EmissionEstimate.new(rental_car) }

  let(:donut) { DonutFactory.new }
  let(:donut_estimate) { Carbon::EmissionEstimate.new(donut) }

  let(:timeframe) { Timeframe.new(:year => 2009) }

  before do
    rental_car_estimate.stub!(:data).and_return({
      'active_subtimeframe' => timeframe,
      'emission' => 23.4,
      'methodology' => 'http://example.com',
      'emission_units' => 'kilograms'
    })
  end

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

  describe '.initialize' do
    it "should ignore invalid options passed to #emission_estimate" do
      e = Carbon::EmissionEstimate.new rental_car, :timeframe => timeframe, :method_missing => 'helo there',
        :response => 'foo'
      e.instance_variable_get(:@timeframe).should be_a(Timeframe)
      e.instance_variable_get(:@method_missing).should be_nil
      e.instance_variable_get(:@response).should be_nil
    end
  end

  describe '#take_options' do
    it 'accepts the :comply option' do
      rental_car_estimate.take_options :comply => :iso
      rental_car_estimate.comply.should == :iso
    end
  end
    
  describe '#key' do
    it 'allows override values' do
      donut_estimate.key = 'ADifferentOne'
      donut_estimate.key.should == 'ADifferentOne'
    end
  end

  describe '#active_subtimeframe' do
    it 'proxies to the response data' do
      rental_car_estimate.active_subtimeframe.should == timeframe
    end
  end
  
  describe '#number' do
    it 'returns nil if a callback is set' do
      rental_car_estimate.callback = CALLBACK_URL
      rental_car_estimate.number.should be_nil
    end
    it 'proxies to the emission data' do
      rental_car_estimate.callback = nil
      rental_car_estimate.number.should be_a(Numeric)
    end
  end

  describe '#emission_units' do
    it 'proxies to the emission data' do
      rental_car_estimate.callback = nil
      rental_car_estimate.emission_units.length.should > 0
    end
  end

  describe '#methodology' do
    it 'proxies to the emission data' do
      rental_car_estimate.callback = nil
      rental_car_estimate.methodology.length.should > 0
    end
  end
  
  describe '#==' do
    it 'provides equality for realtime requests' do
      rental_car_estimate.should == 23.4
    end
    it "should not compare itself to numbers" do
      rental_car_estimate.callback = CALLBACK_URL
      rental_car_estimate.should_not == 0.0
    end
  end
  
  describe '#method_missing' do
    before do
      rental_car_estimate.callback = CALLBACK_URL
    end
    it "doesn't allow coercion to numeric in async mode" do
      lambda {
        rental_car_estimate + 5
      }.should raise_error(Carbon::TriedToUseAsyncResponseAsNumber)
    end
    it "doesn't allow #to_f in async mode" do
      lambda {
        rental_car_estimate.to_f
      }.should raise_error(Carbon::TriedToUseAsyncResponseAsNumber)
    end
    it "raises an error if method isn't found" do
      lambda {
        rental_car_estimate.foobar
      }.should raise_error(NoMethodError, /EmissionEstimate/)
    end
  end
end
