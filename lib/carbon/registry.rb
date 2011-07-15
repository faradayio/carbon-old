require 'singleton'
module Carbon
  class Registry < ::Hash
    include ::Singleton
  end
end
