module Carbon
  class EmissionEstimate
    class Storage
      attr_accessor :parent
      attr_reader :raw_request
      attr_reader :raw_response

      def initialize(parent)
        @parent = parent
      end

      def url
        "#{::Carbon::STORAGE_URL}/#{::Digest::SHA1.hexdigest(parent.key+parent.guid)}"
      end

      def present?
        parent.guid.present? and data.present?
      end

      def data
        return @data[0] if @data.is_a? ::Array
        @raw_request = ::REST::Request.new :get, ::URI.parse(url)
        @raw_response = raw_request.perform
        if raw_response.success?
          @data = [::Carbon::EmissionEstimate.parse(raw_response.body)]
        else
          @data = []
        end
        @data[0]
      end
    end
  end
end
