require 'active_support/core_ext/hash/reverse_merge'

module Travis
  class Instrument
    autoload :Event, 'travis/instrument/event'
    autoload :Task,  'travis/instrument/task'

    class << self
      def attach_to(const)
        namespace = const.name.underscore.gsub('/', '.')
        instance_methods(false).each do |event|
          event = [namespace, event].join('.')
          ActiveSupport::Notifications.subscribe(/^#{event}:call/) do |message, *args|
            begin
              method, event = message.split('.').last.split(':')
              new(args.last).send(method)
            rescue Exception => e
              Travis.logger.error "Could not notify about #{message.inspect} event. #{e.class}: #{e.message}\n#{e.backtrace}"
            end
          end
        end
      end
    end

    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    private

      def publish(data = {})
        # data = data.merge(:thread_id => Thread.current.object_id)
        data = data.reverse_merge(:exception => payload[:exception]) if payload.key?(:exception)

        # somehow publish data to Redis or whatever so we can display it on a simple web interface
        data.each { |key, value| puts "#{key}: #{value}" }
      end
  end
end
