require 'carbon/base'

module Carbon
  module ClassicAPI
    def self.included(target) # :nodoc:
      target.extend ClassMethods
    end

    module ClassMethods
      # Indicate that this class "emits as" an <tt>:automobile</tt>, <tt>:flight</tt>, or another of the Brighter Planet emitter classes.
      #
      # See the {emission estimate web service use documentation}[http://carbon.brighterplanet.com/use]
      #
      # For example,
      #   emit_as :automobile do
      #     provide :make
      #   end
      def emit_as(emitter_common_name, &block)
        Registry.instance[name] = Base.new emitter_common_name
        Blockenspiel.invoke block, carbon_base
      end
      # Third-person singular preferred.
      alias :emits_as :emit_as
      
      def carbon_base # :nodoc:
        Registry.instance[name]
      end
    end
  end
end
