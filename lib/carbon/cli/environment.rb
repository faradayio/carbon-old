module Carbon
  module Cli
    class Environment
      instance_methods.each do |m|
        undef_method(m) if m.to_s !~ /(?:^__|^nil\?$|^send$|^instance_eval$|^define_method$|^class$|^object_id$)/
      end

      def get_binding() binding end
      
      def method_missing(*args)
        return if [:extend, :respond_to?].include? args.first
        puts "Unknown command #{args.first}"
      end
    end
  end
end
