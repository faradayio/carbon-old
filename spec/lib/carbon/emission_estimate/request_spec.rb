require 'spec_helper'

describe Carbon::EmissionEstimate::Request do
  CALLBACK_URL = 'http://www.postbin.org/1dj0146'

  let(:emitter) do
    mock Object,
      :class => mock(Object,
                     :carbon_base => mock(Object,
                                          :emitter_common_name => 'dirigible',
                                          :translation_table => []))
  end
  let(:emission_estimate) { Carbon::EmissionEstimate.new emitter }
  let(:request) { Carbon::EmissionEstimate::Request.new emission_estimate }

  describe '#params' do
    it 'returns a hash of params' do
      request.params.should be_a_kind_of(Hash)
    end
    it 'validates the params' do
      request.should_receive :validate
      request.params
    end
    it 'includes compliance' do
      emission_estimate.comply = :iso
      request.params.should include(:comply => :iso)
    end
  end

  describe '#validate' do
    it 'warns the user if no key is given' do
      Carbon.key = nil
      Carbon.should_receive :warn
      request.validate({})
    end
    it 'does nothing if all parameters are OK' do
      Carbon.should_not_receive :warn
      request.validate(
        :key => 'ABC123'
      )
    end
  end

  describe '#realtime_url' do
    it 'returns a URL for bleeding edge calculations' do
      emission_estimate.certified = false
      request.realtime_url.should =~ /http:\/\/carbon.brighterplanet.com/
    end
    it 'returns a URL for certified calculations' do
      emission_estimate.certified = true
      request.realtime_url.should =~ /http:\/\/certified.carbon.brighterplanet.com/
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
      Carbon.key = 'valid'
      d = DonutFactory.new
      d.emission_estimate.request.body.should =~ /key=valid/
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
  
    it 'should not generate post bodies with lots of empty params' do
      c = RentalCar.new
      c.emission_estimate :timeframe => Timeframe.new(:year => 2009)
      c.emission_estimate.request.body.should_not include('&&')
      c.emission_estimate.request.body.should_not =~ /=[^a-z0-9]/i
    end

    it 'complies to given standards' do
      c = RentalCar.new
      c.emission_estimate(:comply => :iso).request.body.should =~ /comply=iso/
    end
  end

  describe 'asynchronous (queued) requests' do
    it 'should post a message to SQS' do
      c = RentalCar.new
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.request.url.should =~ /queue.amazonaws.com/
    end
    
    it 'should default to non-certified' do
      c = RentalCar.new
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.request.url.should_not =~ /certified/
    end

    it 'should accept certified' do
      c = RentalCar.new
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.certified = true
      c.emission_estimate.request.url.should =~ /certified/
    end
  end
end

