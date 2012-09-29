module Travis
  module Services
    module Hooks
      class Update < Base
        def run
          active = params[:active]
          active = { 'true' => true, 'false' => false }[active] if active.is_a?(String)
          hook.set(params[:active], current_user)
        end

        private

          def hook
            service(:hooks, :one, params).run
          end
      end
    end
  end
end
