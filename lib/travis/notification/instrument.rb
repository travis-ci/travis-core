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

        def method_added(method)
          return unless event = method.to_s.match(/^(.*)_completed$/).try(:captures).try(:first)
          define_method("#{event}_received") { send(method) rescue publish } unless method_defined? "#{event}_received"
          define_method("#{event}_failed")   { send(method) rescue publish } unless method_defined? "#{event}_failed"
        end

        def attach_to(const)
          namespace = const.name.underscore.gsub('/', '.')
          instrumented_methods(const).each do |event, status|
            ActiveSupport::Notifications.subscribe(/^#{namespace}(\..+)?.#{event}:#{status}/) do |message, args|
              publish(message, event, status, args)
            end
          end
        end

        def instrumented_methods(const)
          consts = ancestors.select { |const| const.name[0..5] == 'Travis' }
          methods = consts.map { |const| const.public_instance_methods(false) }.flatten.uniq
          # find methods that end with received, completed, failed and strip the suffix
          methods = methods.map { |method| method.to_s =~ /^(.*)_(received|completed|failed)$/ && $1 }
          # subscribe to each of them with all the suffixes
          methods.compact.uniq.product(%w(received completed failed))
        end

        def publish(message, event, status, args)
          new(message, event, status, args).send("#{event}_#{status}")
        end

        # # TODO this should probably be decoupled somewhere else
        # async :publish, :queue => :instrumentation
      end

      attr_reader :config, :target, :result, :exception, :started_at, :finished_at, :message, :status

      def initialize(message, method, status, payload)
        @target, @result, @exception = payload.values_at(:target, :result, :exception)
        @started_at, @finished_at = payload.values_at(:started_at, :finished_at)
        @config = { :message => message, :method => method, :status => status }
        @config[:exception] = exception if exception
        @status = status.to_sym
      end

      def duration
        @duration ||= (finished_at ? finished_at - started_at : nil)
      end

      private

        def publish(event = {})
          event[:msg] = "#{target.class.name}##{config[:method]} #{event[:msg]}".strip
          payload = { message: config[:message], uuid: Travis.uuid, payload: event }
          payload[:exception] = exception if exception
          Notification.publish(payload)
        end
    end
  end
end
