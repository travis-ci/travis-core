module Travis
  module Addons
    module Webhook
      module Instruments
        class EventHandler < Notification::Instrument::EventHandler
          def notify_completed
            publish(:targets => handler.targets)
          end
        end

        class Task < Notification::Instrument::Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<Build id=#{payload[:id]}>",
              :repository => payload[:repository].values_at(:owner_name, :name).join('/'),
              # :request_id => payload['request_id'], # TODO
              :object_type => 'Build',
              :object_id => payload[:id],
              :targets => task.targets
            )
          end
        end
      end
    end
  end
end

