module Carbon
  class EmissionEstimate
    class Response
      attr_reader :parent
      attr_reader :data
      attr_reader :number
      attr_reader :raw_request
      attr_reader :raw_response
      def initialize(parent)
        @parent = parent
        send "load_#{parent.mode}_data"
      end
      def load_realtime_data # :nodoc:
        attempts = 0
        begin
          response = perform
          raise ::Carbon::RateLimited if response.status_code == 403 and response.body =~ /Rate Limit/i
        rescue ::Carbon::RateLimited
          if attempts < 4
            attempts += 1
            sleep 0.2 * attempts
            retry
          else
            raise $!, "Rate limited #{attempts} time(s) in a row"
          end
        end
        raise ::Carbon::RealtimeEstimateFailed unless response.success?
        @data = ::ActiveSupport::JSON.decode response.body
        instantiate_known_response_objects
        @number = data['emission'].to_f.freeze
      end
      def instantiate_known_response_objects # :nodoc:
        data['active_subtimeframe'] = ::Timeframe.interval(data['active_subtimeframe']) if data.has_key? 'active_subtimeframe'
      end
      def load_async_data # :nodoc:
        response = perform
        raise ::Carbon::QueueingFailed unless response.success?
        @data = {}
        @number = nil
      end
      def perform # :nodoc:
        @raw_request = ::REST::Request.new :post, ::URI.parse(parent.request.url), parent.request.body, {'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'}
        @raw_response = @raw_request.perform
      end
    end
  end
end
