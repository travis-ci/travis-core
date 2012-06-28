require 'mail'

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
            ActiveSupport::Notifications.subscribe(/^#{namespace}(\..+)?.#{event}:call$/) do |message, *args|
              begin
                method, event = message.split('.').last.split(':')
                new(message, args.last).send(method)
              # rescue Exception => e
              #   Travis.logger.error "Could not notify about #{message.inspect} event. #{e.class}: #{e.message}\\n#{e.backtrace}"
              end
            end
          end
        end
      end

      attr_reader :config, :target, :result, :exception, :message

      def initialize(message, payload)
        @target, @result, @exception = payload.values_at(:target, :result, :exception)
        @config = { :result => serialize(result), :message => message }
        @config[:exception] = exception if exception
      end

      private

        def publish(event = {})
          payload = config.merge(:uuid => Travis.uuid, :payload => event)
          Notification.publish(payload)
        end

        def serialize(object)
          case object
          when Mail::Message
            object.to_s
          when Array
            object.map { |element| serialize(element) }
          when Hash
            hash = object.class.new
            object.each_pair { |key, value| hash[serialize(key)] = serialize(value) }
            hash
          when NilClass, TrueClass, FalseClass, String, Symbol, Numeric
            object
          else
            api = Travis::Api.builder(object, :for => 'notification', :version => 'v0')
            api ? api.new(object).data : object
          end
        end
    end
  end
end
