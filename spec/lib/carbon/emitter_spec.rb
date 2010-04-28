require 'spec_helper'

class Bazaar
  include Carbon::Emitter

  attr_accessor :zip_code, :owned, :residents, :square_feet

  emits_as :residence do
    provides :zip_code
    provides :ownership, :with => :owned
    provides :residents
    provides :floorspace_estimate, :with => :square_feet
  end
end

describe Carbon::Emitter do
  let(:emitter) { Bazaar.new }

  describe '#emission' do
    it 'should return an instance of an emissions calculation' do
      stub_http
      emitter.emission.should be_a_kind_of(Carbon::EmissionsCalculation)
    end
    it 'should send the correct options to the emission calculation' do
      mock_calc = mock(Carbon::EmissionsCalculation, :calculate! => true)
      Carbon::EmissionsCalculation.should_receive(:new).
        with(Bazaar.emitter_options, emitter).
        and_return(mock_calc)
      emitter.emission
    end
  end
end
