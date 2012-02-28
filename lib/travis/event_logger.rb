require 'securerandom' # ActiveSupport::Notifications needs this but fails to require it
require 'active_support/notifications'

module Travis
  # Very thin wrapper around ActiveSupport::Notifications.
  # Used for logging and metrics. Will hopefully allow remote debugging.
  #
  # Simple example:
  #
  #   Travis::EventLogger.subscirbe('request') { |_, data| puts data[:payload] }
  #   Travis::EventLogger.notify('request', 'hi there!')
  #
  # Output:
  #
  #   hi there!
  #
  # Complext example:
  #
  #   class Foo
  #     extend Travis::EventLogger
  #
  #     def initialize
  #       notify("outside.foo") { foo }
  #     end
  #
  #     def foo
  #       notify "inside.foo"
  #     end
  #   end
  #
  #   EventLogger.subscribe 'foo' do |name, data|
  #     print "#{name}, scope: #{data[:subject]}, "
  #     print "duration: #{data[:event].duration}, " if data[:instrumented]
  #     puts "something: #{data[:something]}"
  #   end
  #
  #   Foo.new
  #   Travis::EventLogger.scope(something: 42) { Foo.new }
  #
  # Output:
  #
  #   inside.foo.travis, scope: #<Foo:0x007f9bbb83bb30>, something: nil
  #   outside.foo.travis, scope: #<Foo:0x007f9bbb83bb30>, duration: 2 (in milliseconds), something: nil
  #   inside.foo.travis, scope: #<Foo:0x007f9bbb838d18>, something: 42
  #   outside.foo.travis, scope: #<Foo:0x007f9bbb838d18>, duration: 2 (in milliseconds), something: 42
  #
  # TODO: merge with or use in Travis::Notifications
  module EventLogger
    # DSL method corresponding to EventLogger.
    #
    # Usage:
    #
    #   class Foo
    #     include Travis::EventLogger
    #
    #     def something
    #       notify "something.foo", "bar"
    #     end
    #   end
    def notify(event, payload = {}, &block)
      payload = {:payload => payload} unless Hash === payload
      EventLogger.notify(event, payload.merge(:subject => self), &block)
    end

    private :notify

    # Sends an notification suffixed with .travis and with scope values being injected.
    # If a block is passed, it will use instrumentation.
    def self.notify(event, payload = {}, &block)
      payload = {:payload => payload} unless Hash === payload
      payload = scope.merge payload
      event   = "#{event}.travis"
      if block
        payload[:instrumented] = true
        ActiveSupport::Notifications.instrument(event, payload, &block)
      else
        ActiveSupport::Notifications.publish(event, payload)
      end
    end

    # Subscribes to notifications (takes care of the suffix).
    # Automatically captures any prefixed notifirstions.
    def self.subscribe(event = '')
      raise LocalJumpError, 'no block given' unless block_given?
      event = Regexp.escape(event) unless event.is_a? Regexp
      ActiveSupport::Notifications.subscribe(/^(?:.*\.)?#{event}\.travis$/) do |*args|
        name, payload = args.first, args.last
        payload[:event] ||= ActiveSupport::Notifications::Event.new(*args) if payload[:instrumented]
        yield name, payload
      end
    end

    # Allows adding infos to notification payload.
    def self.scope(inject = {})
      scope = Thread.current[:'Travis::EventLogger.scope'] ||= {}
      return scope unless block_given?
      Thread.current[:'Travis::EventLogger.scope'] = scope.merge(inject)
      yield
    ensure
      Thread.current[:'Travis::EventLogger.scope'] = scope
    end
  end
end
