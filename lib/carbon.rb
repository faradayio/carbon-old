require 'carbon/emitter'
require 'carbon/flight'

module Carbon
  class << self
    def api_key
      @api_key if defined?(@api_key)
    end
    def api_key=(val)
      @api_key = val
    end

    def base_url
      @base_url ||= 'http://carbon.brighterplanet.com'
    end
    def base_url=(val)
      @base_url = val
    end
  end
end
