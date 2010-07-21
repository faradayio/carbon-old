module Carbon
  class EmissionEstimate
    class Request
      attr_reader :parent
      def initialize(parent)
        @parent = parent
      end
      def body
        send "#{parent.mode}_body"
      end
      def async_body # :nodoc:
        params = params
        params[:emitter] = parent.emitter.class.carbon_base.emitter_common_name
        params[:callback] = parent.callback
        params[:callback_content_type] = parent.callback_content_type
        {
          :Action => 'SendMessage',
          :Version => '2009-02-01',
          :MessageBody => params.to_query
        }.to_query
      end
      def realtime_body # :nodoc:
        params.to_query
      end
      # Used internally, but you can look if you want.
      #
      # Returns the params hash that will be send to the emission estimate server.
      def params
        params = parent.emitter.class.carbon_base.translation_table.inject({}) do |memo, translation|
          characteristic, key = translation
          if characteristic.is_a? ::Array
            current_value = parent.emitter.send characteristic[0]
            as = characteristic[1]
          else
            current_value = parent.emitter.send characteristic
            as = characteristic
          end
          current_value = current_value.to_param
          if current_value.present?
            if key
              memo[as] ||= {}
              memo[as][key] = current_value
            else
              memo[as] = current_value
            end
          end
          memo
        end
        params[:timeframe] = parent.timeframe if parent.timeframe
        params[:key] = parent.key if parent.key
        params
      end
      def realtime_url # :nodoc:
        "#{::Carbon::REALTIME_URL}/#{parent.emitter.class.carbon_base.emitter_common_name.pluralize}.json"
      end
      def async_url # :nodoc:
        ::Carbon::ASYNC_URL
      end
      def url
        send "#{parent.mode}_url"
      end
    end
  end
end
