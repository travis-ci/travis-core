require 'active_support/core_ext/object/blank'
require 'core_ext/module/async'

module Travis
  module Event
    class Handler
      autoload :Campfire,     'travis/event/handler/campfire'
      autoload :Email,        'travis/event/handler/email'
      autoload :Flowdock,     'travis/event/handler/flowdock'
      autoload :GithubStatus, 'travis/event/handler/github_status'
      autoload :Hipchat,      'travis/event/handler/hipchat'
      autoload :Irc,          'travis/event/handler/irc'
      autoload :Metrics,      'travis/event/handler/metrics'
      autoload :Pusher,       'travis/event/handler/pusher'
      autoload :Trail,        'travis/event/handler/trail'
      autoload :Webhook,      'travis/event/handler/webhook'

      # autoload :Archive,            'travis/event/handler/archive'
      # autoload :Github,             'travis/event/handler/github'
      # autoload :Worker,             'travis/event/handler/worker'

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
