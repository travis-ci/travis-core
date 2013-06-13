module Travis
  module Services
    class FindHooks < Base
      register :find_hooks

      def run
        current_user.service_hooks(params).includes(:permissions).select('*, permissions.admin as admin')
      end
    end
  end
end
