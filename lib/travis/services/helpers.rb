module Travis
  module Services
    module Helpers
      def run_service(key, *args)
        service(key, *args).run
      end

      def service(key, *args)
        params = args.last.is_a?(Hash) ? args.pop : {}
        user = args.last
        user ||= current_user if respond_to?(:current_user)
        const = service_class(key)
        const.new(user, params)
      end

      def service_class(key)
        Travis::Services.services[key.to_sym] || raise("can not use unregistered service #{key}")
      end
    end
  end
end
