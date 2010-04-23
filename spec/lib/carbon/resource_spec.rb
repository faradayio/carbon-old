require 'spec_helper'

class Gremlin
  include Carbon::Resource
  resource_name :fritos
end

class Kimchee
  include Carbon::Resource
end

class Ninja
  include Carbon::Emitter

  characteristics :sword, :extra_weapon, :name
end

describe Carbon::Resource do
  describe '.resource_name' do
    it 'should set the resource_name to the given value' do
      Gremlin.resource_name.should == 'fritos'
    end
    it 'should default to the pluralized class name' do
      Kimchee.resource_name.should == 'kimchees'
    end
    it 'should work for modules that mix in Emitter' do
      Ninja.resource_name.should == 'ninjas'
    end
  end

  describe '#resource' do
    let(:gremlin) { Gremlin.new }
    before(:all) { Gremlin.send(:public, :resource) }
    it 'should return the resource' do
      gremlin.resource.should be_a_kind_of(RestClient::Resource)
    end
    it 'should initialize a resource with a URL for the given emitter' do
      gremlin.resource.url.should == 'http://carbon.brighterplanet.com/fritos'
    end
  end

  describe '#fields' do
    let(:ninja) { Ninja.new }
    before(:all) { Ninja.send(:public, :fields) }
    it 'should generate a hash of fields to be posted' do
      ninja.name = 'Kawai Aki-no-kami'
      ninja.sword = 'katana'
      ninja.fields.should include(
        'name' => 'Kawai Aki-no-kami',
        'sword' => 'katana'
      )
    end
    it 'should convert has values into sub-hash fields' do
      ninja.extra_weapon = { :throwing_star => 'pointy' }
      ninja.fields.should include(
        'extra_weapon' => { 'throwing_star' => 'pointy' }
      )
    end
  end
end
