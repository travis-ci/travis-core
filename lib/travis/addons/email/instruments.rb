module Travis
  module Addons
    module Email
      module Instruments
        class EventHandler < Notification::Instrument::EventHandler
          def notify_completed
            publish(:recipients => handler.recipients)
          end
        end

        class Task < Notification::Instrument::Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<Build id=#{payload[:build][:id]}>",
              :repository => payload[:repository][:slug],
              # :request_id => payload['request_id'], # TODO
              :object_type => 'Build',
              :object_id => payload[:build][:id],
              :email => task.type,
              :recipients => task.recipients
            )
          end
        end
      end
    end
  end
end
