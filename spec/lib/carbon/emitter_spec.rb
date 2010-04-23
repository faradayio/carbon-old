require 'spec_helper'

class Bazaar
  include Carbon::Emitter
end

describe Carbon::Emitter do
  let(:response) do
    { 'emission' => 134.599, 'methodology' => 'http://carbon.brighterplanet.com/something' }
  end
  let(:emitter) { Bazaar.new }

  describe '#methodology_url' do
    it 'should raise an error if no calculation has been performed' do
      expect { emitter.methodology }.to raise_error(Carbon::Emitter::NotYetCalculated)
    end
    it 'should return the url' do
      emitter.instance_variable_set(:@methodology, 'http://foo/bar')
      emitter.instance_variable_set(:@result, 'not nil')
      emitter.methodology.should == 'http://foo/bar'
    end
  end

  describe '#calculate!' do
    before(:each) do
      emitter.stub!(:fetch_calculation)
      emitter.stub!(:result).and_return(response)
    end
    it 'should calculate by fetching data from the web service' do
      emitter.should_receive(:fetch_calculation)
      emitter.calculate!
    end
    it 'should set emission' do
      emitter.calculate!
      emitter.emission.should == 134.599
    end
    it 'should set methodology' do
      emitter.calculate!
      emitter.methodology.should == 'http://carbon.brighterplanet.com/something'
    end
  end
end
