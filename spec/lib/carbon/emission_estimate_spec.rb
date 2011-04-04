require 'spec_helper'

describe Carbon::EmissionEstimate do
  describe '#take_options' do
    it 'accepts the :comply option' do
      estimate = Carbon::EmissionEstimate.new
      estimate.take_options :comply => :iso
      estimate.comply.should == :iso
    end
  end
end

