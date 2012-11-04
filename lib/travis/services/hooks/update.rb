module Travis
  module Services
    module Hooks
      class Update < Base
        def run
          service(:github, :set_hook, id: params[:id], active: active?).run
          repo.update_column(:active, active?)
        end

        # TODO
        # def messages
        #   messages = []
        #   messages << { :notice => "The service hook was successfully #{active? ? 'enabled' : 'disabled'}." } if what?
        #   messages << { :error  => 'The service hook could not be set.' } unless what?
        #   messages
        # end

        private

          def repo
            @repo ||= service(:hooks, :find_one, params).run
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
