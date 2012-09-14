module Travis
  module Services
    class Base
      attr_reader :current_user

      def initialize(current_user = nil)
        @current_user = current_user
      end

      def scope(key)
        key.to_s.camelize.constantize
      end
    end
  end
end
