module Travis
  module Notifications
    class Handler
      autoload :Archive,  'travis/notifications/handler/archive'
      autoload :Campfire, 'travis/notifications/handler/campfire'
      autoload :Email,    'travis/notifications/handler/email'
      autoload :Github,   'travis/notifications/handler/github'
      autoload :Irc,      'travis/notifications/handler/irc'
      autoload :Pusher,   'travis/notifications/handler/pusher'
      autoload :Webhook,  'travis/notifications/handler/webhook'
      autoload :Worker,   'travis/notifications/handler/worker'

      class << self
        def call(event, object, data = {})
          new(event, object, data).call
        end
      end

      include Logging

      attr_reader :event, :object, :data

      def initialize(event, object, data = {})
        @event = event
        @object = object
        @data = data
      end

      def call
        handle if handle?
      end

      def handle?
        true
      end
    end
  end
end
