module Travis
  module Notifications

    # Notification handlers subscribe to events issued from core models (such
    # as Build, Job::Configure and Job::Test).
    #
    # Subscriptions are defined in Travis.config so they can easily be
    # added/removed for an environment.
    #
    # Subscribing classes are supposed to define an EVENTS constant which holds
    # a regular expression which will be matched against the event name.
    class Subscription
      attr_reader :name, :subscriber, :patterns

      include Module.new {
        def initialize(name)
          @name = name
          @subscriber = Handler.const_get(name.to_s.camelize)
          @patterns = Array(subscriber::EVENTS)
        end

        def notify(event, *args)
          subscriber.new.notify(event, *args) if matches?(event)
        end

        def matches?(event)
          patterns.any? { |patterns| patterns.is_a?(Regexp) ? patterns.match(event) : patterns == event }
        end
      }
    end
  end
end

