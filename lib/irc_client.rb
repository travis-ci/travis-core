# Very (maybe too) simple IRC client that is used for IRC notifications.
#
# based on:
# https://github.com/sr/shout-bot
#
# other libs to take note of:
# https://github.com/tbuehlmann/ponder
# https://github.com/cinchrb/cinch
# https://github.com/cho45/net-irc
require 'socket'

class IrcClient
  attr_accessor :socket, :ping_thread

  def initialize(server, nick, options = {})
    @socket = TCPSocket.open(server, options[:port] || 6667)

    @ping_thread = start_ping_thread

    socket.puts "PASS #{options[:password]}" if options[:password]
    socket.puts "NICK #{nick}"
    socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
  end

  def join(channel, key = nil)
    socket.puts "JOIN ##{channel} #{key}".strip
  end

  def run(&block)
    instance_eval(&block) if block_given?
  end

  def leave(channel)
    socket.puts "PART ##{channel}"
  end

  def say(message, channel, use_notice = false)
    message_type = use_notice ? "NOTICE" : "PRIVMSG"
    socket.puts "#{message_type} ##{channel} :#{message}"
  end

  def quit
    socket.puts 'QUIT'
    socket.gets until socket.eof?
    ping_thread.exit
  end

  private

  def start_ping_thread
    Thread.new(socket) do |s|
      loop do
        s.puts "PONG #{$1}" if s.gets =~ /^PING (.*)/
      end
    end
  end
end

