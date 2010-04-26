module Carbon
  module Emitter
    class Characteristic
      attr_accessor :name, :field

      def self.from_options_hash(name, options)
        new(:name => name, :field => options[:as])
      end

      def initialize(options = {})
        options.each { |name, value| self.send("#{name}=", value) unless value.nil? }
      end

      def field
        @field ||= self.name
      end
    end
  end
end
