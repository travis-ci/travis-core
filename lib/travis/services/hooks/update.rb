module Travis
  module Services
    module Hooks
      class Update < Base
        def run
          hook.set(active?, current_user) if hook
        end

        private

          def hook
            @hook ||= service(:hooks, :one, params).run
          end

          def active?
            active = params[:active]
            active = { 'true' => true, 'false' => false }[active] if active.is_a?(String)
            !!active
          end
      end
    end
  end
end
