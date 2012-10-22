module Travis
  module Notification
    class Instrument
      module Event
        class Handler < Instrument
          class Archive < Handler
          end

          class Campfire < Handler
            def notify_completed
              publish(:targets => handler.targets)
            end
          end

          class Email < Handler
            def notify_completed
              publish(:recipients => handler.recipients)
            end
          end

          class Flowdock < Handler
            def notify_completed
              publish(:targets => handler.targets)
            end
          end

          class Github < Handler
            def notify_completed
              publish(:url => handler.url)
            end
          end

          class GithubCommitStatus < Handler
            def notify_completed
              publish(:url => handler.params[:url])
            end
          end

          class Hipchat < Handler
            def notify_completed
              publish(:targets => handler.targets)
            end
          end

          class Irc < Handler
            def notify_completed
              publish(:channels => handler.channels)
            end
          end

          class Pusher < Handler
            def notify_completed
              super unless handler.event.to_s == 'job:test:log'
            end
          end

          class Webhook < Handler
            def notify_completed
              publish(:targets => handler.targets)
            end
          end

          class Worker < Handler
            def notify_completed
              publish(
                :repository => object.repository.slug,
                :request_id => object.request_id
              )
            end
          end

          attr_reader :handler, :object, :args, :result

          def initialize(message, status, payload)
            @handler, @args, @result = payload.values_at(:target, :args, :result)
            @object = handler.object
            super
          end

          def notify_completed
            publish
          end

          def publish(event = {})
            event = event.reverse_merge(
              :msg => "#{handler.class.name}#notify(#{handler.event}) for #<#{object.class.name} id=#{object.id}>",
              :object_type => object.class.name,
              :object_id => object.id,
              :event => handler.event
            )

            if handler.respond_to?(:payloads)
              event[:payloads] = handler.payloads
            elsif handler.respond_to?(:payload)
              event[:payload] = handler.payload
            end

            event[:request_id] = object.request_id if object.respond_to?(:request_id)
            event[:repository] = object.repository.slug if object.respond_to?(:repository)
            super(event)
          end
        end
      end
    end
  end
end
