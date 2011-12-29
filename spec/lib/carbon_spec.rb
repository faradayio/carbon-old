require 'spec_helper'

EXISTING_UNIQUE_ID = 'oisjoaioijodijaosijdoias'
MISSING_UNIQUE_ID = 'd09joijdoijaloijdoais'
OTHER_UNIQUE_ID = '1092fjoid;oijsao;ga'

describe Carbon do
  before(:each) do
    Carbon.key = 'ABC123'
  end
  
  it 'is simple to use' do
    c = RentalCar.new
    c.model = 'Acura'
    c.model_year = 2003
    c.fuel_economy = 32

    VCR.use_cassette '2003 Acura' do
      c.emission_estimate.to_f.should == 1.258809844501948
      c.emission_estimate.emission_units.should == 'kilograms'
    end
  end
  
  describe 'with caching' do
    it "keeps around estimates if the parameters don't change" do
      c = RentalCar.new
      c.model = 'Acura'
      c.model_year = 2003
      c.fuel_economy = 32

      VCR.use_cassette '2003 Acura' do
        c.emission_estimate.to_f.should == 1.258809844501948
      end
      
      first_raw_request = c.emission_estimate.response.raw_request
      c.emission_estimate.to_f.should == 1.258809844501948
      c.emission_estimate.response.raw_request.object_id.should == first_raw_request.object_id
    end
    
    it "recalculates if parameters change" do
      c = RentalCar.new
      c.model = 'Acura'
      c.model_year = 2003
      c.fuel_economy = 32

      VCR.use_cassette '2003 Acura' do
        c.emission_estimate.should == 1.258809844501948
      end

      first_raw_request = c.emission_estimate.response.raw_request
      c.model = 'Honda'

      VCR.use_cassette '2003 Honda' do
        c.emission_estimate.to_f.should == 134.599
        c.emission_estimate.response.raw_request.object_id.should_not == first_raw_request.object_id
      end
    end
    
    it "recalculates if parameters change (through the options hash)" do
      c = RentalCar.new
      c.model = 'Acura'
      c.model_year = 2003
      c.fuel_economy = 32
      c.emission_estimate.to_f.should == 134.599
      first_raw_request = c.emission_estimate.response.raw_request
      c.emission_estimate(:timeframe => Timeframe.new(:year => 2009)).should == 134.599
      c.emission_estimate.response.raw_request.object_id.should_not == first_raw_request.object_id
    end
    
    it "recalculates if the callback changes" do
      c = RentalCar.new
      c.model = 'Acura'
      c.emission_estimate.should == 134.599
      first_raw_request = c.emission_estimate.response.raw_request
      c.emission_estimate.callback = CALLBACK_URL
      c.emission_estimate.response.raw_request.object_id.should_not == first_raw_request.object_id
    end
  end
  
  describe 'requests that can be stored (cached) by guid' do
    it 'should find existing unique ids on S3' do
      d = DonutFactory.new
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID).should == 1234
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID).updated_at.should be_instance_of(Time)
    end
    it "should pass through to realtime if unique id isn't found on S3" do
      d = DonutFactory.new
      d.emission_estimate(:guid => MISSING_UNIQUE_ID).should == 1000
      d.emission_estimate(:guid => MISSING_UNIQUE_ID).response.data.keys.should_not include('updated_at')
      d1 = DonutFactory.new
      d1.emission_estimate(:guid => MISSING_UNIQUE_ID).should == 9876
      d1.emission_estimate(:guid => MISSING_UNIQUE_ID).updated_at.should be_instance_of(Time)
    end
    it "should depend on the user to update the guid if they want a new estimate" do
      d = DonutFactory.new
      d.oven_count = 12_000
      str1 = d.emission_estimate(:guid => EXISTING_UNIQUE_ID).methodology
      str1.should equal(d.emission_estimate(:guid => EXISTING_UNIQUE_ID).methodology)
      d.oven_count = 13_000
      str1.should equal(d.emission_estimate(:guid => EXISTING_UNIQUE_ID).methodology)
      str1.should_not equal(d.emission_estimate(:guid => OTHER_UNIQUE_ID).methodology)
    end
    it 'should be deferrable for use in 2-pass reporting systems' do
      d = DonutFactory.new
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID, :defer => true).number.should be_nil
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID, :defer => true).request.url.should =~ /amazonaws/
    end
    it 'should complain if you provide defer but not guid' do
      d = DonutFactory.new
      lambda {
        d.emission_estimate(:defer => true).request.params
      }.should raise_error(ArgumentError, /defer.*guid/i)
    end
    it 'should complain if you provide guid and callback' do
      d = DonutFactory.new
      lambda {
        d.emission_estimate(:defer => true, :callback => 'foobar').request.params
      }.should raise_error(ArgumentError, /callback.*defer/i)
    end
    it 'should send guid along with other parameters when queueing up deferred request' do
      d = DonutFactory.new
      d.emission_estimate(:guid => EXISTING_UNIQUE_ID, :defer => true).request.params[:MessageBody].should =~ /#{EXISTING_UNIQUE_ID.to_query(:guid)}/
    end
  end
end
