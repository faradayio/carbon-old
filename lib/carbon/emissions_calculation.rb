module Carbon
  class EmissionsCalculation
    attr_accessor :value, :options, :source

    def initialize(options, source)
      self.options = options
      self.source = source
    end
  end
end
