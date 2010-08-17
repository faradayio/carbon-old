module Carbon
  class EmissionEstimate
    class Request
      attr_reader :parent

      def initialize(parent)
        @parent = parent
      end

      def body
        params.to_query
      end

      def params
        send "#{parent.mode}_params"
      end

      def async_params # :nodoc:
        raise ::ArgumentError, "When using :callback you cannot specify :defer" if parent.defer? and parent.callback
        raise ::ArgumentError, "When using :defer => true you must specify :guid" if parent.defer? and parent.guid.blank?
        hash = _params
        hash[:emitter] = parent.emitter.class.carbon_base.emitter_common_name
        hash[:callback] = parent.callback if parent.callback
        hash[:callback_content_type] = parent.callback_content_type if parent.callback
        hash[:guid] = parent.guid if parent.defer?
        {
          :Action => 'SendMessage',
          :Version => '2009-02-01',
          :MessageBody => hash.to_query
        }
      end

      def realtime_params # :nodoc:
        _params
      end

      # Used internally, but you can look if you want.
      #
      # Returns the params hash that will be send to the emission estimate server.
      def _params
        hash = parent.emitter.class.carbon_base.translation_table.inject({}) do |memo, translation|
          characteristic, key = translation
          if characteristic.is_a? ::Array
            current_value = parent.emitter.send characteristic[0]
            as = characteristic[1]
          else
            current_value = parent.emitter.send characteristic
            as = characteristic
          end
          current_value = begin
            current_value.to_characteristic
          rescue NoMethodError
            current_value.to_param
          end
          if current_value.is_a?(FalseClass) or current_value.present?
            if key
              memo[as] ||= {}
              memo[as][key] = current_value
            else
              memo[as] = current_value
            end
          end
          memo
        end
        hash[:timeframe] = parent.timeframe if parent.timeframe
        hash[:key] = parent.key if parent.key
        hash
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
