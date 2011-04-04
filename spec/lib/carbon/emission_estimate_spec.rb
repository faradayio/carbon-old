require 'spec_helper'

describe Carbon::EmissionEstimate do
  describe '#take_options' do
    it 'accepts the :complies option' do
      estimate = Carbon::EmissionEstimate.new
      estimate.take_options :complies => :iso
      estimate.complies.should == :iso
    end
  end
end

