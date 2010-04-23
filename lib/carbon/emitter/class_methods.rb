module Carbon
  module Emitter
    module ClassMethods
      def characteristics(*args)
        if args.empty?
          @characteristics
        else
          @characteristics = args
          self.instance_eval { attr_accessor *@characteristics }
        end
      end
    end
  end
end
