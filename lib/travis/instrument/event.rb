module Travis
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

        def initialize(payload)
          @handler, @args, @result = payload.values_at(:target, :args, :result)
          @object = handler.object
          super
        end

        def notify
          publish
        end

        def publish(data = {})
          super(data.reverse_merge(
            :message => "#{handler.class.name}#notify(#{handler.event}) for #<#{object.class.name} id=#{object.id}>",
            :repository => object.repository.slug,
            :request_id => object.request_id,
            :object_type => object.class.name,
            :object_id => object.id,
            :payload => handler.payload
          ))
        end
      end
    end
  end
end
