require 'active_support/core_ext/object/try'
require 'core_ext/hash/compact'

module Travis
  module Notification
    class Instrument
      autoload :EventHandler, 'travis/notification/instrument/event_handler'
      autoload :Services,     'travis/notification/instrument/services'
      autoload :Task,         'travis/notification/instrument/task'

      class << self
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
      end

      attr_reader :target, :method, :status, :result, :meta

      def initialize(message, method, status, payload)
        @method, @status = method, status
        @target, @result = payload.values_at(:target, :result)
        started_at, finished_at = payload.values_at(:started_at, :finished_at)
        @meta = {
          uuid:        Travis.uuid,
          message:     message,
          started_at:  started_at,
          finished_at: finished_at,
          duration:    finished_at ? finished_at - started_at : nil,
          exception:   payload[:exception]
        }.compact
      end

      def publish(event = {})
        event[:msg] = "#{target.class.name}##{method} #{event[:msg]}".strip
        Notification.publish(meta.merge(payload: event))
      end
    end
  end
end
