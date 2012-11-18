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
  end
end

Backports.require_relative_dir 'services'
