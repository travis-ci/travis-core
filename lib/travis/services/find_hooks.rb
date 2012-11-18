module Travis
  module Services
    class FindHooks < Base
      def run
        current_user.service_hooks(params)
      end
    end
  end
end
