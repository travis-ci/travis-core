module Support
  module Mocks
    class Irc
      def initialize
        @output = []
      end

      def join(channel, password = nil, &block)
        out "JOIN ##{channel} #{password}".strip
      end

      def run(&block)
        yield(self) if block_given?
      end

      def leave(channel)
        out "PART ##{channel}"
      end

      def say(message, channel, use_notice = false)
        message_type = use_notice ? "NOTICE" : "PRIVMSG"
        out "#{message_type} ##{channel} :#{message}"
      end

      def quit
        out "QUIT"
      end

      def out(output)
        @output << output
      end

      def output
        @output
      end
    end
  end
end
