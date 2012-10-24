require 'mail'
require 'active_support/core_ext/object/try'
require 'thread'

module Travis
  module Notification
    class Instrument
      autoload :Event,    'travis/notification/instrument/event'
      autoload :Services, 'travis/notification/instrument/services'
      autoload :Task,     'travis/notification/instrument/task'

      class << self
        extend Travis::Async

        def method_added(method)
          return unless event = method.to_s.match(/^(.*)_completed$/).try(:captures).try(:first)
          define_method("#{event}_received") { send(method) rescue publish } unless method_defined? "#{event}_received"
          define_method("#{event}_failed")   { send(method) rescue publish } unless method_defined? "#{event}_failed"
        end

        def attach_to(const)
          namespace = const.name.underscore.gsub('/', '.')
          # TODO could instead somehow figure out or keep track of instrumented methods?
          consts = ancestors.select { |const| const.name[0..5] == 'Travis' }
          methods = consts.map { |const| const.public_instance_methods(false) }.flatten.uniq

          methods.each do |method|
            next unless match = method.to_s.match(/^(.*)_(completed|failed|received)$/)
            event, status = match.captures
            ActiveSupport::Notifications.subscribe(/^#{namespace}(\..+)?.#{event}:#{status}/) do |message, args|
              publish(message, status, args, method)
            end
          end
        end

        def publish(message, status, args, method)
          new(message, status, args).send(method)
        end

        # # TODO this should probably be decoupled somewhere else
        # async :publish, :queue => :instrumentation
      end

      attr_reader :config, :target, :result, :exception, :started_at, :finished_at, :message, :status

      def initialize(message, status, payload)
        @target, @result, @exception = payload.values_at(:target, :result, :exception)
        @started_at, @finished_at = payload.values_at(:started_at, :finished_at)
        @config = { :message => message }
        @config[:exception] = exception if exception
        @status = status.to_sym
      end

      def duration
        @duration ||= (finished_at ? finished_at - started_at : nil)
      end

      private

        def publish(event = {})
          Notification.publish(config.merge(uuid: Travis.uuid, payload: event))
        end
    end
  end
end
