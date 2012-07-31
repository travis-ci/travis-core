require 'core_ext/module/async'

module Travis
  module Event
    class Handler
      autoload :Archive,            'travis/event/handler/archive'
      autoload :Campfire,           'travis/event/handler/campfire'
      autoload :Email,              'travis/event/handler/email'
      autoload :Github,             'travis/event/handler/github'
      autoload :GithubCommitStatus, 'travis/event/handler/github_commit_status'
      autoload :Hipchat,            'travis/event/handler/hipchat'
      autoload :Irc,                'travis/event/handler/irc'
      autoload :Metrics,            'travis/event/handler/metrics'
      autoload :Pusher,             'travis/event/handler/pusher'
      autoload :Webhook,            'travis/event/handler/webhook'
      autoload :Worker,             'travis/event/handler/worker'

      include Logging
      extend  Instrumentation

      class << self
        def notify(event, object, data = {})
          new(event, object, data).notify
        end
      end

      attr_reader :event, :object, :data

      def initialize(event, object, data = {})
        @event = event
        @object = object
        @data = data
      end

      def notify
        handle if handle?
      end
      # TODO ask mathias about the scope
      instrument :notify # , :scope => :event
    end
  end
end
