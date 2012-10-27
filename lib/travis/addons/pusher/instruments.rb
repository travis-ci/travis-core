module Travis
  module Addons
    module Pusher
      module Instruments
        class EventHandler < Notification::Instrument::EventHandler
          def notify_completed
            super unless handler.event.to_s == 'job:test:log'
          end
        end

        class Task < Notification::Instrument::Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<#{type.camelize} id=#{id}> (channels: #{task.channels.join(', ')})",
              # :repository => payload[:repository][:slug],
              # :request_id => payload['request_id'], # TODO
              :object_type => type.camelize,
              :object_id => id,
              :event => task.event,
              :client_event => task.client_event,
              :channels => task.channels
            ) unless task.event.to_s == 'job:test:log'
          end

          def type
            @type ||= task.event.split(':').first
          end

          def id
            # TODO ugh. should be better with API v2
            payload.key?(type.to_sym) ? payload[type.to_sym][:id] : payload[:id]
          end
        end
      end
    end
  end
end

