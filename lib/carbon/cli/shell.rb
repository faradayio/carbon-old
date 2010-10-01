module Carbon
  module Cli
    class Shell < Environment
      emitters_url = "http://carbon.brighterplanet.com/models.json"
      response = REST.get(emitters_url)
      if true || response.ok?
        @emitters = JSON.parse(response.body)
        @emitters.each do |e|
          define_method e.to_sym do |*args|
            if args.any? && num = args.first && saved = $emitters[e.to_sym][num]
              IRB.start_session(saved.get_binding)
            else
              emitter e.to_sym
            end
          end
        end
      else
        puts "  => Sorry, emitter types couldn't be retrieved (via #{emitters_url})"
        done
      end
      
      def help
        puts "  => #{@@emitters.join ', '}"
      end
      
      def to_s
        'carbon-'
      end
      
      def key(k)
        @key = k
        puts "  => Using key #{k}"
      end

      def emitter(e)
        ::IRB.start_session(Emitter.new(e, @key).get_binding)
      end
    end
  end
end
