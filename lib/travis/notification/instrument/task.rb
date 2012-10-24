module Travis
  module Notification
    class Instrument
      class Task < Instrument
        class Campfire < Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<Build id=#{payload[:build][:id]}>",
              :repository => payload[:repository][:slug],
              # :request_id => payload['request'][:id], # TODO
              :object_type => 'Build',
              :object_id => payload[:build][:id],
              :targets => task.targets,
              :message => task.message
            )
          end
        end

        class Flowdock < Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<Build id=#{payload[:build][:id]}>",
              :repository => payload[:repository][:slug],
              # :request_id => payload['request'][:id], # TODO
              :object_type => 'Build',
              :object_id => payload[:build][:id],
              :targets => task.targets,
              :message => task.message
            )
          end
        end

        class Hipchat < Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<Build id=#{payload[:build][:id]}>",
              :repository => payload[:repository][:slug],
              # :request_id => payload['request'][:id], # TODO
              :object_type => 'Build',
              :object_id => payload[:build][:id],
              :targets => task.targets,
              :message => task.message
            )
          end
        end

        class Email < Task
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

        class GithubStatus < Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<Build id=#{payload[:build][:id]}>",
              :repository => payload[:repository][:slug],
              # :request_id => payload['request_id'], # TODO
              :object_type => 'Build',
              :object_id => payload[:build][:id],
              :url => task.url.to_s
            )
          end
        end

        class Irc < Task
          def run_completed
            publish(
              :msg => "#{task.class.name}#run for #<Build id=#{payload[:build][:id]}>",
              :repository => payload[:repository][:slug],
              # :request_id => payload['request_id'], # TODO
              :object_type => 'Build',
              :object_id => payload[:build][:id],
              :channels => task.channels,
              :messages => task.messages
            )
          end
        end

        class Pusher < Task
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

        class Webhook < Task
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

        attr_reader :task, :payload

        def initialize(message, status, payload)
          @task = payload[:target]
          @payload = task.payload
          super
        end

        def run_completed
          publish
        end

        def publish(event = {})
          event[:msg] = "#{event[:msg]} #{queue_info}" if Travis::Async.enabled? && Travis::Task.run_local?
          super(event.merge(:payload => self.payload))
        end

        private

          def queue_info
            "(queue size: #{queue.items.size})" if queue
          end

          def queue
            Travis::Async::Threaded.queues[task.class.name]
          end
      end
    end
  end
end
