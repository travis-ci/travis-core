require 'active_support/core_ext/object/blank'
require 'core_ext/module/async'

module Travis
  module Event
    class Handler
      autoload :Metrics, 'travis/event/handler/metrics'
      autoload :Trail,   'travis/event/handler/trail'

      include Logging
      extend  Instrumentation

      class << self
        def notify(event, object, data = {})
          payload = Api.data(object, for: 'event', version: 'v0', params: data) if object.is_a?(Build)
          handler = new(event, object, data, payload)
          handler.notify if handler.handle?
        end
      end

      attr_reader :event, :object, :data, :payload

      def initialize(event, object, data = {}, payload = nil)
        @event   = event
        @object  = object
        @data    = data
        @payload = payload
      end

      def notify
        handle
      end
      # TODO disable instrumentation in tests
      instrument :notify

      private

          def config
            @config ||= Config.new(payload)
          end

          def repository
            @repository ||= payload['repository']
          end

          def job
            @job ||= payload['job']
          end

          def build
            @build ||= payload['build']
          end

          def request
            @request ||= payload['request']
          end

          def commit
            @commit ||= payload['commit']
          end

          def pull_request?
            build['pull_request']
          end
    end
  end
end
