module Carbon
  # You will probably never access this class directly. Instead, you'll touch it through the DSL.
  #
  # An instance of this appears on any class that includes <tt>Carbon</tt>.
  class Base
    include Blockenspiel::DSL
    attr_reader :klass
    attr_reader :emitter_common_name
    def initialize(klass, emitter_common_name)
      @klass = klass
      @emitter_common_name = emitter_common_name.to_s
    end
    # A completed translation table will look like:
    # {[:mixer, :size]=>"mixer_size",
    # :personnel=>:employees,
    # :smokestack_size=>"smokestack_size",
    # :oven_count=>"oven_count",
    # [:mixer, :wattage]=>"mixer_wattage"}
    def translation_table #:nodoc:
      @translation_table ||= Hash.new
    end
    # Indicate that you will send in a piece of data about the emitter.
    #
    # If you don't use the <tt>:as</tt> option, the name of the getter method will be guessed.
    #
    # There are two optional parameters:
    # * <tt>:of</tt> - the owner of a nested characteristic. So to send <tt>model[name]</tt> you write <tt>provide :name, :of => :model</tt>
    # * <tt>:as</tt> - the local getter name. So if Brighter Planet expects <tt>fuel_efficiency</tt>, and you only have <tt>fuel_economy</tt>, you can write <tt>provide :fuel_efficiency, :as => :fuel_economy</tt>.
    #
    # For example:
    #
    #    emit_as :automobile do
    #      provide :make                                    # "I will send the value of #make as 'make=X'"
    #      provide :model, :as => :my_funny_name_for_model  # "I will send the value of #my_funny_name_for_model as 'model=X'"
    #      provide :name,  :of => :make                     # "I will send the value of #make_name as make[name]=X" (note: getter method name was guessed)
    #    end
    #--
    # sabshere 7/17/10 - is this a good place to allow a "units" option? this would probably just be for enforcement, i don't think we would accept non-standard units
    #++
    def provide(attr_name, options = {})
      options = options.symbolize_keys
      characteristic = if options.has_key? :of
        # [ :mixer, :size ]
        [options[:of], attr_name]
      else
        # :oven_count
        attr_name
      end
      # translation_table[[:mixer,:size]] = 'mixer_size'
      translation_table[characteristic] = options[:as] || Array.wrap(characteristic).join('_')
    end
    # japanese-style preferred
    alias :provides :provide
  end
end
