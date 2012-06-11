module Travis
  class Instrument
    class Task < Instrument
      class Archive < Task
        def run
          publish
        end
      end

      class Campfire < Task
        def run
          publish
        end
      end

      class Email < Task
        def run
          publish #(:recipients => handler.recipients)
        end
      end

      class Github < Task
        def run
          publish #(:url => handler.url)
        end
      end

      class Irc < Task
        def run
          publish #(:channels => handler.channels)
        end
      end

      class Pusher < Task
      end

      class Webhook < Task
        def run
          publish #(:targets => handler.targets)
        end
      end

      class Worker < Task
        def run
          publish #(:queue => object.queue, :payload => handler.payload)
        end
      end

      def run
        publish
      end

      def publish(data = {})
        super(data.reverse_merge(
          # :message => "#{handler.class.name}#run(#{handler.event}) for #<#{object.class.name} id=#{object.id}>",
          # :repository => object.repository.slug,
          # :request_id => object.request_id,
          # :object_type => object.class.name,
          # :object_id => object.id,
          :data => data
        ))
      end
    end
  end
end
