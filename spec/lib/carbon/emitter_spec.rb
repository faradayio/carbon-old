require 'spec_helper'

class Bazaar
  include Carbon::Emitter

  attr_accessor :zip_code, :owned, :residents, :square_feet

  emits_as :residence do
    provides :zip_code
    provides :ownership, :as => :owned
    provides :residents
    provides :floorspace_estimate, :as => :square_feet
  end
end

describe Carbon::Emitter do
  let(:emitter) { Bazaar.new }

  describe '#emissions' do
    it 'should return an instance of an emissions calculation' do
      emitter.emissions.should be_a_kind_of(Carbon::EmissionsCalculation)
    end
    it 'should send the correct options to the emission calculation' do
      Carbon::EmissionsCalculation.should_receive(:new).with(Bazaar.emitter_options, emitter)
      emitter.emissions
    end
  end
end
