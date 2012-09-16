module Travis
  module Services
    class Hooks < Base
      def find_all(params = {})
        current_user.service_hooks(params)
      end

      def find_one(params)
        repository(params).service_hook
      end

      def update(params)
        repository(params).tap do |repo|
          repo.service_hook.set(params[:active] == 'true', current_user)
        end
      end

      private

        def repository(params)
          current_user.repositories.administratable.find_by(params) || raise(ActiveRecord::RecordNotFound)
        end
    end
  end
end
