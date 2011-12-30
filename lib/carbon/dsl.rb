module Carbon
  module DSL
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
        Registry.instance[name] = Mapper.new emitter_common_name
        Blockenspiel.invoke block, carbon_base
      end
      # Third-person singular preferred.
      alias :emits_as :emit_as
      
      def carbon_base # :nodoc:
        Registry.instance[name]
      end
    end

    class Mapper
      include Blockenspiel::DSL

      attr_reader :emitter_common_name
      
      def initialize(emitter_common_name)
        @emitter_common_name = emitter_common_name.to_s
      end

      # A completed translation table will look like:
      # {[:mixer, :size]=>"mixer_size",
      # :personnel=>:employees,
      # :smokestack_size=>"smokestack_size",
      # :oven_count=>"oven_count",
      # [:mixer, :wattage]=>"mixer_wattage"}
      def translation_table # :nodoc:
        @translation_table ||= Hash.new
      end
      
      def reset_translation_table! #:nodoc:
        @translation_table = Hash.new
      end

      # Indicate that you will send in a piece of data about the emitter.
      #
      # Two general rules:
      # * Take note of what Brighter Planet expects to receive. If you send <tt>fuel_economy</tt> and we're expecting <tt>fuel_efficiency</tt>, we won't understand! (Hint: use the <tt>:as</tt> option.)
      # * Make sure <tt>#to_characteristic</tt> or <tt>#to_param</tt> is set up. The gem always calls one of these (it will try <tt>#to_characteristic</tt> first) before sending, so that's your change to key things by "EPA code" (fictional) or whatever else you want. (Hint: use the <tt>:key</tt> option.)
      #
      # There are two optional parameters:
      # * <tt>:as</tt> - if Brighter Planet expects <tt>fuel_efficiency</tt>, and you say <tt>mpg</tt>, you can write <tt>provide :mpg, :as => :fuel_efficiency</tt>. This will result in a query like <tt>?fuel_efficiency=XYZ</tt>.
      # * <tt>:key</tt> - if Brighter Planet expects a make's name ("Nissan") and you want to look things up by (fictional) "EPA code", you could say <tt>provide :make, :key => :epa_code</tt>. This will result in a query like <tt>?make[epa_code]=ABC</tt>.
      #
      #                                                                  # What's sent to Brighter Planet
      #    emit_as :automobile do                                        
      #      provide :mpg,  :as => :fuel_efficiency                      # fuel_efficiency=my_car.mpg.to_param
      #      provide :make, :key => :epa_code                            # make[epa_code]=my_car.make.to_param
      #      # or really shaking things up...
      #      provide :manufacturer, :as => :make, :key => :epa_code      # make[epa_code]=my_car.manufacturer.to_param
      #    end
      #
      # Note that no matter what you send to us, the gem always calls <b><tt>#to_characteristic</tt></b> (or, failing that, <tt>#to_param</tt>) on the emitter. In this example, it's up to you to make sure my_car.manufacturer.to_param returns an epa_code.
      def provide(attr_name, options = {})
        options = options.symbolize_keys
        characteristic = if options.has_key? :as
          # [ :mpg, :fuel_efficiency ]
          [attr_name, options[:as]]
        else
          # :make
          attr_name
        end
        # translation_table[:make] = 'epa_code'
        translation_table[characteristic] = options[:key]
      end

      # Third-person singular preferred.
      alias :provides :provide
    end
  end
end
