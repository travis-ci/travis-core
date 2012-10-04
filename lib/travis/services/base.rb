module Travis
  module Services
    class Base
      include Services

      attr_reader :current_user, :params

      def initialize(current_user = nil, params = {})
        @current_user = current_user
        @params = params.symbolize_keys
      end

      def scope(key)
        key.to_s.camelize.constantize
      end
    end
  end
end
