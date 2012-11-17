module Travis
  module Services
    class Base
      include Services

      def self.register(key)
        Travis::Services.register(key, self)
      end

      attr_reader :current_user, :params

      def initialize(*args)
        @params = args.last.is_a?(Hash) ? args.pop.symbolize_keys : {}
        @current_user = args.last
      end

      def scope(key)
        key.to_s.camelize.constantize
      end

      def logger
        Travis.logger
      end
    end
  end
end
