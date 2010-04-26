require 'carbon/emitter/characteristic'

module Carbon
  module Emitter
    class Options
      attr_accessor :emitter_type, :characteristics

      def initialize(emitter_type)
        self.emitter_type = emitter_type.to_sym
      end

      def characteristics
        @characteristics ||= {}
      end

      def provides(characteristic_name, options = {})
        characteristics[characteristic_name] = 
          Carbon::Emitter::Characteristic.from_options_hash(characteristic_name, options)
      end
    end
  end
end
