module Travis
  module Notifications
    class Subscription
      attr_reader :name, :subscriber, :patterns

      include Module.new {
        def initialize(name)
          @name = name
          @subscriber = Handler.const_get(name.to_s.camelize)
          @patterns = Array(subscriber::EVENTS)
        end

        def notify(event, *args)
          instrument(event, *args) do
            subscriber.new.notify(event, *args) if matches?(event)
          end
        end

        def matches?(event)
          patterns.any? { |patterns| patterns.is_a?(Regexp) ? patterns.match(event) : patterns == event }
        end
      }

      include Async, Instrumentation
    end
  end
end

