module Travis
  module Notification
    class Instrument
      module Event
        class Handler < Instrument
          class Archive < Handler
          end

          class Campfire < Handler
            def notify
              publish(:targets => handler.targets)
            end
          end

          class Email < Handler
            def notify
              publish(:recipients => handler.recipients)
            end
          end

          class Github < Handler
            def notify
              publish(:url => handler.url)
            end
          end

          class Irc < Handler
            def notify
              publish(:channels => handler.channels)
            end
          end

          class Pusher < Handler
          end

          class Webhook < Handler
            def notify
              publish(:targets => handler.targets)
            end
          end

          class Worker < Handler
            def notify
              publish(:queue => object.queue, :payload => handler.payload)
            end
          end

          attr_reader :handler, :object, :args, :result

          def initialize(message, payload)
            @handler, @args, @result = payload.values_at(:target, :args, :result)
            @object = handler.object
            super
          end

          def notify
            publish
          end

          def publish(event = {})
            event = event.reverse_merge(
              :msg => "#{handler.class.name}#notify(#{handler.event}) for #<#{object.class.name} id=#{object.id}>",
              :object_type => object.class.name,
              :object_id => object.id,
              :event => handler.event,
              :payload => handler.payload
            )
            event[:request_id] = object.request_id if object.respond_to?(:request_id)
            event[:repository] = object.repository.slug if object.respond_to?(:repository)
            super(event)
          end
        end
      end
    end
  end
end
