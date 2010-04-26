require 'carbon/emitter/options'

module Carbon
  module Emitter
    module ClassMethods
      def emits_as(emitter_type, &blk)
        self.emitter_type = emitter_type

        self.emitter_options = Carbon::Emitter::Options.new(emitter_type)
        self.emitter_options.instance_eval &blk if block_given?
      end

      def emitter_type; @emitter_type; end
      def emitter_type=(val); @emitter_type = val; end

      def emitter_options; @emitter_options; end
      def emitter_options=(val); @emitter_options = val; end
    end
  end
end
