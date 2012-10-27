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
require 'openssl'

module Travis
  module Addons
    module Irc
      class Client
        attr_accessor :channel, :socket, :ping_thread

        def self.wrap_ssl(socket)
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE # TODO!
          OpenSSL::SSL::SSLSocket.new(socket, ssl_context).tap do |sock|
            sock.sync = true
            sock.connect
          end
        end

        def initialize(server, nick, options = {})
          Travis.logger.info("Connecting to #{server} on port #{options[:port] || 6667} with nick #{options[:nick]}")

          @socket = TCPSocket.open(server, options[:port] || 6667)
          @socket = self.class.wrap_ssl(@socket) if options[:ssl]
          @ping_thread = start_ping_thread

          socket.puts "PASS #{options[:password]}" if options[:password]
          socket.puts "NICK #{nick}"
          socket.puts "PRIVMSG NickServ :IDENTIFY #{options[:nickserv_password]}" if options[:nickserv_password]
          socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
        end

        def join(channel, key = nil)
          socket.puts "JOIN ##{channel} #{key}".strip
        end

        def run(&block)
          yield(self) if block_given?
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
          socket.close
          ping_thread.exit
        end

        private

          def start_ping_thread
            Thread.new(socket) do |s|
              loop do
                s.puts "PONG #{$1}" if s.gets =~ /^PING (.*)/
                sleep 0.2
              end
            end
          end
      end
    end
  end
end

