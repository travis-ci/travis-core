require 'core_ext/module/async'

module Travis
  module Event
    class Handler
      autoload :Configure, 'travis/event/handler/configure'
      autoload :Request,   'travis/event/handler/request'
      autoload :Test,      'travis/event/handler/test'

      autoload :Archive,   'travis/event/handler/archive'
      autoload :Campfire,  'travis/event/handler/campfire'
      autoload :Email,     'travis/event/handler/email'
      autoload :Github,    'travis/event/handler/github'
      autoload :Irc,       'travis/event/handler/irc'
      autoload :Pusher,    'travis/event/handler/pusher'
      autoload :Webhook,   'travis/event/handler/webhook'
      autoload :Worker,    'travis/event/handler/worker'

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
