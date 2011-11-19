require 'logger'
require 'active_support/notifications'

STDOUT.sync = true

module Travis
  class LogFormatter < Logger::Formatter
    def call(severity, timestamp, progname, msg)
      "#{String === msg ? msg : msg.inspect}\n"
    end
  end

  class << self
    def logger
      @logger ||= Logger.new(STDOUT).tap do |logger|
        logger.formatter = LogFormatter.new
      end
    end

    def logger=(logger)
      @logger = logger
    end
  end

  module Logging
    ANSI = {
      :red    => 31,
      :green  => 32,
      :yellow => 33,
      :cyan   => 36
    }

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def new(*args)
        super(*args).tap do |instance|
          (class << instance; self; end).send(:include, instrumentations)
        end
      end

      def instrumentations
        @instrumentations ||= Module.new
      end

      def instrument(name)
        instrumentations.send(:define_method, name) do |*args|
          ActiveSupport::Notifications.instrument(name, [self] + args) do
            super(*args)
          end
        end
      end
    end

    def log(*args)
      logger.info(*args)
      STDOUT.flush
    end

    def logger
      Travis.logger
    end

    def notice(message)
      log colorize(:yellow, message)
    end

    def colorize(color, text)
      "\e[#{ANSI[color]}m#{text}\e[0m"
    end
  end
end
