module Travis
  module Notification
    class Instrument
      autoload :Event,     'travis/notification/instrument/event'
      autoload :Task,      'travis/notification/instrument/task'

      class << self
        def attach_to(const)
          namespace = const.name.underscore.gsub('/', '.')
          # TODO could instead somehow figure out or keep track of instrumented methods?
          consts = ancestors.select { |const| const.name[0..5] == 'Travis' }
          methods = consts.map { |const| const.public_instance_methods(false) }.flatten.uniq

          methods.each do |event|
            event = [namespace, event].join('.')
            ActiveSupport::Notifications.subscribe(/^#{event}:call/) do |message, *args|
              begin
                method, event = message.split('.').last.split(':')
                new(args.last).send(method)
              # rescue Exception => e
              #   Travis.logger.error "Could not notify about #{message.inspect} event. #{e.class}: #{e.message}\\n#{e.backtrace}"
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

        def publish(event)
          event.merge!(:result => payload[:result])
          event.merge!(:exception => payload[:exception]) if payload.key?(:exception)
          Notification.publish(event)
        end
    end
  end
end
