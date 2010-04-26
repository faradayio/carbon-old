require 'carbon/resource'
require 'carbon/emitter/class_methods'

module Carbon
  module Emitter
    class NotYetCalculated < StandardError; end

    def self.included(target)
      target.extend Carbon::Emitter::ClassMethods
    end

    def emissions
      @emissions ||= Carbon::EmissionsCalculation.new(self.class.emitter_options, self)
    end
  end
end
