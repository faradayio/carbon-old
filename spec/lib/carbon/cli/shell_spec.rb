require 'spec_helper'
require 'carbon/cli/shell'

describe Carbon::Cli::Shell do
  let(:json) { %{
["Automobile","AutomobileTrip","BusTrip","Computation","Diet","Flight","FuelPurchase","Lodging","Meeting","Motorcycle","Pet","Purchase","RailTrip","Residence"]
  } }
  let(:mock_response) { mock(REST, :ok? => true, :body => json) }
  let(:shell) { Carbon::Cli::Shell.new }


  before(:each) do
    REST.stub!(:get).and_return mock_response
  end

  describe '.init' do
    it 'should create methods for each model' do
      Carbon::Cli::Shell.init
      Carbon::Cli::Shell.instance_methods.should include(:automobile)
    end
    it 'should exit if the models cannot be fetched' do
      pending

      mock_response.stub!(:ok?).and_return false
      Carbon::Cli::Shell.should_receive :done
      Carbon::Cli::Shell.init
    end
  end
end

