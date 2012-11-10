module Travis
  module Services
    module Hooks
      class Update < Base
        extend Travis::Instrumentation

        def run
          if hook
            hook.set(active?, current_user)
            true
          end
        end
        instrument :run

        # TODO change hook.set to communicate result and GH errors
        # def messages
        #   messages = []
        #   messages << { :notice => "The service hook was successfully #{active? ? 'enabled' : 'disabled'}." } if what?
        #   messages << { :error  => 'The service hook could not be set.' } unless what?
        #   messages
        # end

        def hook
          @hook ||= service(:hooks, :find_one, params).run
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
