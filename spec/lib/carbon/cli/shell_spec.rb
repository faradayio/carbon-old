require 'spec_helper'
require 'carbon/cli/shell'

describe Carbon::Cli::Shell do
  let(:shell) { Carbon::Cli::Shell.new }

  describe '.init' do
    it 'should create methods for each model' do
      Carbon::Cli::Shell.init
      Carbon::Cli::Shell.instance_methods.should include('automobile')
    end
  end
end

