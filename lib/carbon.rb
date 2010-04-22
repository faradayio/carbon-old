
module Carbon
  class << self
    def api_key
      @api_key if defined?(@api_key)
    end
    def api_key=(val)
      @api_key = val
    end
  end
end
