require 'mail'
require 'active_support/core_ext/object/try'
require 'thread'

module Travis
  module Notification
    class Instrument
      autoload :EventHandler, 'travis/notification/instrument/event_handler'
      autoload :Services,     'travis/notification/instrument/services'
      autoload :Task,         'travis/notification/instrument/task'

      class << self
        extend Travis::Async

        def attach_to(const)
          namespace = const.name.underscore.gsub('/', '.')
          statuses = %w(received completed failed)
          instrumented_methods(const).product(statuses).each do |method, status|
            ActiveSupport::Notifications.subscribe(/^#{namespace}(\..+)?.#{method}:#{status}/) do |message, args|
              publish(message, method, status, args)
            end
          end
        end

        def instrumented_methods(const)
          consts = ancestors.select { |const| const.name[0..5] == 'Travis' }
          methods = consts.map { |const| const.public_instance_methods(false) }.flatten.uniq
          methods = methods.map { |method| method.to_s =~ /^(.*)_(received|completed|failed)$/ && $1 }
          methods.compact.uniq
        end

        def publish(message, method, status, payload)
          instrument = new(message, method, status, payload)
          event = :"#{method}_#{status}"
          instrument.respond_to?(event) ? instrument.send(event) : instrument.publish
        end

        # # TODO this should probably be decoupled somewhere else
        # async :publish, :queue => :instrumentation
      end

      attr_reader :message, :method, :status, :target, :result, :exception, :started_at, :finished_at

      def initialize(message, method, status, payload)
        @message, @method, @status = message, method, status.to_sym
        @target, @result, @exception = payload.values_at(:target, :result, :exception)
        @started_at, @finished_at = payload.values_at(:started_at, :finished_at)
      end

      def duration
        @duration ||= (finished_at ? finished_at - started_at : nil)
      end

      def publish(event = {})
        event[:msg] = "#{target.class.name}##{method} #{event[:msg]}".strip
        payload = { message: message, uuid: Travis.uuid, payload: event }
        payload[:exception] = exception if exception
        Notification.publish(payload)
      end
    end
  end
end
