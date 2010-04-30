require 'spec_helper'

describe Carbon::Emitter::Options do
  let(:options) { Carbon::Emitter::Options.new(:flight) }

  describe '#provides' do
    it 'should note the given field that the class provides' do
      options.provides :date
      options.keys.should include(:date)
      options[:date].should be_an_instance_of(Carbon::Emitter::Characteristic)
    end
    it 'should store options for a given field' do
      options.provides :time_of_day, :with => :flight_date
      options[:time_of_day].field.should == :flight_date
    end
    it 'should accept a block in which subfields are defined' do
      options.provides :engine do
        provides :displacement
        provides :fuel, :with => :fuel_type
      end
      options[:engine][:displacement].should be_an_instance_of(Carbon::Emitter::Characteristic)
      options[:engine][:fuel].field.should == :fuel_type
    end
    it 'should create an options sub item if a block of subfields is given' do
      options.provides :color do
        provides :hue
        provides :saturation
        provides :lightness
      end
      options[:color].should be_an_instance_of Carbon::Emitter::Options
    end
  end
end
