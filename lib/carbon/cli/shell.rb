require 'carbon/cli/environment'
require 'brighter_planet_metadata'

module Carbon
  module Cli
    class Shell < Environment
      def self.emitters
        ::BrighterPlanet.metadata.emitters
      end
      
      def self.init
        emitters.map(&:underscore).each do |e|
          define_method e.to_sym do |*args|
            if args.any? and num = args.first and saved = $emitters[e.to_sym][num]
              emitter e.to_sym, saved
            else
              emitter e.to_sym
            end
          end
        end
      end
      
      def help
        puts "  => #{self.class.emitters.join ', '}"
      end
      
      def to_s
        'carbon-'
      end
      
      def key(k)
        ::Carbon.key = k
        puts "  => Using key #{::Carbon.key}"
      end

      def emitter(e, saved = {})
        ::IRB.start_session(Emitter.new(e, saved).get_binding)
      end
    end
  end
end
