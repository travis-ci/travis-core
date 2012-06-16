module Travis
  module Notification
    class Instrument
      autoload :Event,   'travis/notification/instrument/event'
      autoload :Github,  'travis/notification/instrument/github'
      autoload :Request, 'travis/notification/instrument/request'
      autoload :Task,    'travis/notification/instrument/task'

      class << self
        def attach_to(const)
          namespace = const.name.underscore.gsub('/', '.')
          # TODO could instead somehow figure out or keep track of instrumented methods?
          consts = ancestors.select { |const| const.name[0..5] == 'Travis' }
          methods = consts.map { |const| const.public_instance_methods(false) }.flatten.uniq

          methods.each do |event|
            ActiveSupport::Notifications.subscribe(/^#{namespace}(\..+)?.#{event}:call/) do |message, *args|
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

      attr_reader :payload, :target, :result, :exception

      def initialize(payload)
        @payload = payload
        @target, @result, @exception = payload.values_at(:target, :result, :exception)
      end

      private

        def publish(event = {})
          event.merge!(:result => serialize(result), :uuid => Travis.uuid)
          event.merge!(:exception => exception) if exception
          Notification.publish(event)
        end

        def serialize(object)
          case object
          when NilClass, TrueClass, FalseClass, String, Symbol, Numeric, Array, Hash, Mail::Message
            object
          else
            Travis::Api.data(object, :for => 'notification', :version => 'v0')
          end
        end
    end
  end
end
