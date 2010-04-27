require 'carbon/emitter/class_methods'

module Carbon
  module Emitter
    class NotYetCalculated < StandardError; end

    def self.included(target)
      target.extend Carbon::Emitter::ClassMethods
    end

    def emission
      return @emission unless @emission.nil?
      @emission = Carbon::EmissionsCalculation.new(self.class.emitter_options, self)
      @emission.calculate!
      @emission
    end
  end
end
