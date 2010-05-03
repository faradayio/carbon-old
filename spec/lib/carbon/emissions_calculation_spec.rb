require 'spec_helper'

class DonutFactory
  include Carbon::Emitter

  attr_accessor :smokestack_size, :oven_count, 
    :mixer_size, :mixer_wattage, :employees

  emits_as :factory do
    provides :smokestack_size
    provides :oven_count
    provides :mixer do
      provides :size, :with => :mixer_size
      provides :wattage, :with => :mixer_wattage
    end
    provides :personnel, :with => :employees
  end
end

describe Carbon::EmissionsCalculation do
  let(:response) do
    { 'emission' => 134.599, 'methodology' => 'http://carbon.brighterplanet.com/something' }
  end
  let(:options) { DonutFactory.emitter_options }
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

  describe '#fields' do
    it 'should not send fields that are not set' do
      fields = calculation.send(:fields, options)
      fields[:factory].keys.should_not include(:oven_count)
      fields[:factory].keys.should_not include(:mixer)
    end
    it 'should properly handle sub-fields' do
      donut_factory.mixer_size = 'large'
      donut_factory.mixer_wattage = 1400

      fields = calculation.send(:fields, options)
      fields[:factory][:mixer][:size].should == 'large'
      fields[:factory][:mixer][:wattage].should == 1400
    end
    it 'should not overwrite other fields if sub-fields are given' do
      donut_factory.oven_count = 22
      donut_factory.mixer_size = 'large'
      donut_factory.mixer_wattage = 1400
      donut_factory.employees = 1024

      fields = calculation.send(:fields, options)
      fields[:factory][:oven_count].should == 22
      fields[:factory][:mixer][:size].should == 'large'
      fields[:factory][:mixer][:wattage].should == 1400
      fields[:factory][:personnel].should == 1024
    end
  end
end
