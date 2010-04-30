require 'carbon/emitter/characteristic'

module Carbon
  module Emitter
    class Options
      attr_accessor :name, :characteristics

      def initialize(name)
        self.name = name ? name.to_sym : nil
      end

      def keys
        characteristics.map { |c| c.name }
      end

      def [](characteristic_name)
        characteristics.find { |c| c.name == characteristic_name }
      end

      def characteristics
        @characteristics ||= []
      end

      def provides(characteristic_name, options = {}, &blk)
        if block_given?
          sub_options = self.class.new(characteristic_name)
          sub_options.instance_eval &blk
          characteristics << sub_options
        else
          characteristics <<
            Carbon::Emitter::Characteristic.from_options_hash(characteristic_name, options)
        end
      end
    end
  end
end
