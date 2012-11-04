module Travis
  module Notification
    class Instrument
      module Services
        module Hooks
          class Update < Instrument
            def run_completed
              publish(
                :msg => "#{target.class.name}#run for #{target.repo.slug} active=#{target.active?.inspect} (#{target.current_user.login})",
                :result => result
              )
            end
          end
        end
      end
    end
  end
end
