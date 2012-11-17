require 'backports'

module Travis
  module Services
    class << self
      def services
        @services ||= {}
      end

      def register(key, const)
        services[key] = const
      end
    end

    def run_service(key, *args)
      service(key, *args).run
    end

    def service(key, *args)
      params = args.last.is_a?(Hash) ? args.pop : {}
      user = args.last
      user ||= current_user if respond_to?(:current_user)
      const = Travis::Services.services[key.to_sym] || raise("can not use unregistered service #{key}")
      const.new(user, params)
    end
  end
end

Backports.require_relative_dir 'services'
