require 'spec_helper'

describe Carbon::EmissionEstimate::Response do
  let(:parent) { mock(Object, :mode => :realtime) }
  let(:response) { Carbon::EmissionEstimate::Response.new parent }
  let(:rest_response) { mock(Object, :success? => true, :status_code => 200,
                             :body => 'OK') }

  describe '#load_realtime_data' do
    before do
      ::Carbon::EmissionEstimate.stub! :parse
      response.stub! :sleep
    end

    it 'should retry a request that is rate limited' do
      response.should_receive(:perform).once.ordered.
        and_raise ::Carbon::RateLimited
      response.should_receive(:perform).once.ordered.
        and_return rest_response

      response.send :load_realtime_data
    end

    it 'should not rescue from generic network errors' do
      response.should_receive(:perform).once.ordered.
        and_raise EOFError

      lambda {
        response.send :load_realtime_data
      }.should raise_error EOFError
    end
  end

  describe '#perform' do
    it 'times out if timeout is set' do
      parent.stub!(:timeout).and_return 1
      Timeout.should_receive :timeout
      response.perform
    end
    it 'does not time out if not timeout is set' do
      response.stub! :perform_request
      parent.stub!(:timeout).and_return nil
      Timeout.should_not_receive :timeout
      response.perform
    end
  end
end
