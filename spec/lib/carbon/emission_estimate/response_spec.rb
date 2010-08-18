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

    it 'should retry a request that gets cut off (server disappears mid-request)' do
      response.should_receive(:perform).once.ordered.
        and_raise EOFError
      response.should_receive(:perform).once.ordered.
        and_return rest_response

      response.send :load_realtime_data
    end
  end
end

