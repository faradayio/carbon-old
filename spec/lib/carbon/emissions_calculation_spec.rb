require 'spec_helper'

class DonutFactory
  include Carbon::Emitter
end

describe Carbon::EmissionsCalculation do
  let(:response) do
    { 'emission' => 134.599, 'methodology' => 'http://carbon.brighterplanet.com/something' }
  end
  let(:options) { Carbon::Emitter::Options.new(:residence) }
  let(:donut_factory) { DonutFactory.new }
  let(:calculation) { Carbon::EmissionsCalculation.new(options, donut_factory) }

  describe '#methodology_url' do
    it 'should raise an error if no calculation has been performed' do
      expect { calculation.methodology_url }.to raise_error(Carbon::EmissionsCalculation::NotYetCalculated)
    end
    it 'should return the url' do
      calculation.instance_variable_set(:@methodology_url, 'http://foo/bar')
      calculation.instance_variable_set(:@result, 'not nil')
      calculation.methodology_url.should == 'http://foo/bar'
    end
  end
  describe '#value' do
    it 'should raise an error if no calculation has been performed' do
      expect { calculation.value }.to raise_error(Carbon::EmissionsCalculation::NotYetCalculated)
    end
    it 'should return the url' do
      calculation.instance_variable_set(:@value, 'http://foo/bar')
      calculation.instance_variable_set(:@result, 'not nil')
      calculation.value.should == 'http://foo/bar'
    end
  end
  describe '#calculate!' do
    before(:each) do
      calculation.stub!(:fetch_calculation)
      calculation.stub!(:result).and_return(response)
    end
    it 'should calculate by fetching data from the web service' do
      calculation.should_receive(:fetch_calculation)
      calculation.calculate!
    end
    it 'should set value' do
      calculation.calculate!
      calculation.value.should == 134.599
    end
  end
end
