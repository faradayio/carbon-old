require 'spec_helper'

describe Carbon::Flight do
  let(:emitter) { Carbon::Flight.new }
  it_should_behave_like Carbon::Emitter.to_s
end
