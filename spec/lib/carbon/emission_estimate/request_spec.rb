require 'spec_helper'

describe Carbon::EmissionEstimate::Request do
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
      emission_estimate.complies = :iso
      request.params.should include(:complies => :iso)
    end
  end

  describe '#validate' do
    it 'warns the user if no key is given' do
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
end

