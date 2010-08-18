module Carbon
  class EmissionEstimate
    class Response
      attr_reader :parent
      attr_reader :data
      attr_reader :raw_request
      attr_reader :raw_response

      def initialize(parent)
        @parent = parent
      end

      def load_data
        send "load_#{parent.mode}_data"
      end

    private
      def load_realtime_data # :nodoc:
        attempts = 0
        response = nil
        begin
          response = perform
          raise ::Carbon::RateLimited if response.status_code == 403 and response.body =~ /Rate Limit/i  #TODO: Should we expect an HTTP 402: payment required, instead?
        rescue ::Carbon::RateLimited
          if attempts < 4
            attempts += 1
            sleep 0.2 * attempts
            retry
          else
            raise $!
          end
        end
        raise ::Carbon::RealtimeEstimateFailed unless response.success? #TODO: should we expect 300s as well as 200s? Also, we may want to include response code and body in our exception.
        @data = ::Carbon::EmissionEstimate.parse response.body
      end

      def load_async_data # :nodoc:
        response = perform
        raise ::Carbon::QueueingFailed unless response.success? #TODO: should we expect 300s as well as 200s? Also, we may want to include response code and body in our exception.
        @data = {}
      end

    private
      def perform # :nodoc:
        response = nil
        if parent.timeout
          ::SystemTimer.timeout_after(parent.timeout) do
            response = perform_request
          end
        else
          response = perform_request
        end
        response
      end

      def perform_request # :nodoc:
        @raw_request = ::REST::Request.new :post, ::URI.parse(parent.request.url), parent.request.body, {'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'}
        @raw_response = raw_request.perform
      end
    end
  end
end
