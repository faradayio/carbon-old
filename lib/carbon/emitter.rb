require 'carbon/resource'
require 'carbon/emitter/class_methods'

module Carbon
  module Emitter
    class NotYetCalculated < StandardError; end
    include Resource

    def self.included(target)
      target.extend Carbon::Emitter::ClassMethods
    end

    def initialize(args = {})
      args.each do |name, value|
        next unless self.class.characteristics.include?(name.to_sym)
        self.send("#{name}=", value)
      end
    end

    def methodology
      raise Emitter::NotYetCalculated if result.nil?
      @methodology
    end

    def emission
      raise Emitter::NotYetCalculated if result.nil?
      @emission
    end

    def calculate!
      fetch_calculation
      @emission = result['emission']
      @methodology = result['methodology']
    end
  end
end
