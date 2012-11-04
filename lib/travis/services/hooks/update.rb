module Travis
  module Services
    module Hooks
      class Update < Base
        extend Travis::Instrumentation

        def run
          service(:github, :set_hook, id: params[:id], active: active?).run
          repo.update_column(:active, active?)
        end
        instrument :run

        # TODO
        # def messages
        #   messages = []
        #   messages << { :notice => "The service hook was successfully #{active? ? 'enabled' : 'disabled'}." } if what?
        #   messages << { :error  => 'The service hook could not be set.' } unless what?
        #   messages
        # end

        def repo
          # TODO this service is only used here, so i guess we can inline it
          @repo ||= service(:hooks, :find_one, params).run
        end

        def active?
          active = params[:active]
          active = { 'true' => true, 'false' => false }[active] if active.is_a?(String)
          !!active
        end

        Notification::Instrument::Services::Hooks::Update.attach_to(self)
      end
    end
  end
end
