module Travis
  module Services
    module Hooks
      class Update < Base
        def run
          repository(params).tap do |repo|
            params[:active] = { 'true' => true, 'false' => false }[params[:active]] if params[:active].is_a?(String)
            repo.service_hook.set(params[:active], current_user)
          end
        end

        private

          def repository(params)
            current_user.repositories.administratable.find_by(params) || raise(ActiveRecord::RecordNotFound)
          end
      end
    end
  end
end
