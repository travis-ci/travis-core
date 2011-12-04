require 'girl_friday'

module Travis
  module Notifications
    module Async
      class ErrorHandler # TODO
        def handle(ex)
          puts ex.message
        end
      end

      def notify(event, *args)
        queues[name].push([subscriber, event, *args]) if matches?(event)
      end

      protected

        def queues
          @queues ||= Travis.config.notifications.inject({}) do |queues, name|
            queues.merge(name => queue_for(name))
          end
        end

        def queue_for(name)
          # TODO should be able to detach and use the old/overwritten #notify method instead of the block
          GirlFriday::WorkQueue.new(name, options_for(name)) do |subscriber, event, *args|
            begin
              instrument(event, *args) do
                subscriber.new.notify(event, *args) if matches?(event)
              end
            rescue Exception => e
              log_exception(e)
            end
          end
        end

        def options_for(name)
          { :size => Travis.config.async[name].try(:size) || 1, :error_handler => ErrorHandler }
        end
    end
  end
end

