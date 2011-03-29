require 'spec_helper'
require 'carbon/shell'

describe Carbon::Shell do
  it 'should create methods for each model' do
    Carbon::Shell.instance_methods.should include('automobile')
  end
end
