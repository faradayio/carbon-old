require 'carbon/cli/environment'

module Carbon
  module Cli
    class Shell < Environment
      cattr_accessor :emitters
      
      def self.init
        emitters_url = "http://carbon.brighterplanet.com/models.json"
        response = REST.get(emitters_url)
        if true || response.ok?
          self.emitters = ActiveSupport::JSON.decode response.body
          emitters.map(&:underscore).each do |e|
            define_method e.to_sym do |*args|
              if args.any? and num = args.first and saved = $emitters[e.to_sym][num]
                emitter e.to_sym, saved
              else
                emitter e.to_sym
              end
            end
          end
        else
          puts "  => Sorry, emitter types couldn't be retrieved (via #{emitters_url})"
          done
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
