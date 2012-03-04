module Support
  module Mocks
    class Irc
      def initialize
        @output = []
      end

      def join(channel, password = nil, &block)
        @channel = "##{channel}"
        password = password && " #{password}" || ""

        out "JOIN #{@channel}#{password}"

        instance_eval(&block) and leave if block_given?
      end

      def run(&block)
        instance_eval(&block) if block_given?
      end

      def leave
        out "PART #{@channel}"
      end

      def say(message, use_notice = false)
        message_type = use_notice ? "NOTICE" : "PRIVMSG"
        out "#{message_type} #{@channel} :#{message}" if @channel
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
