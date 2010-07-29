module Carbon
  class EmissionEstimate
    class Response
      attr_reader :parent
      attr_reader :data
      attr_reader :raw_request
      attr_reader :raw_response
      def initialize(parent)
        @parent = parent
        send "load_#{parent.mode}_data"
      end
      def load_realtime_data # :nodoc:
        attempts = 0
        begin
          ::SystemTimer.timeout_after(2) do
            response = perform
          end
          raise ::Carbon::RateLimited if response.status_code == 403 and response.body =~ /Rate Limit/i
        rescue ::Timeout::Error
          raise ::Carbon::SlowResponse
        rescue ::Carbon::RateLimited
          if attempts < 4
            attempts += 1
            sleep 0.2 * attempts
            retry
          else
            raise $!
          end
        end
        raise ::Carbon::RealtimeEstimateFailed unless response.success?
        @data = ::Carbon::EmissionEstimate.parse response.body
      end
      def load_async_data # :nodoc:
        response = perform
        raise ::Carbon::QueueingFailed unless response.success?
        @data = {}
      end
      def perform # :nodoc:
        @raw_request = ::REST::Request.new :post, ::URI.parse(parent.request.url), parent.request.body, {'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'}
        @raw_response = raw_request.perform
      end
    end
  end
end
