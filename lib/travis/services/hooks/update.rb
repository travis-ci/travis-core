module Travis
  module Services
    module Hooks
      class Update < Base
        def run
          hook.set(active?, current_user) if hook
        end

        # TODO change hook.set to communicate result and GH errors
        # def messages
        #   messages = {}
        #   messages[:notice] = "The service hook was successfully #{active? ? 'enabled' : 'disabled'}." if what?
        #   messages[:error]  = 'The service hook could not be set.' unless what?
        #   messages
        # end

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
