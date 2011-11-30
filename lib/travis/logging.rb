# require 'logger'
# require 'active_support/notifications'
#
# STDOUT.sync = true
#
# module Travis
#   class LogFormatter < Logger::Formatter
#     def call(severity, timestamp, progname, msg)
#       "#{String === msg ? msg : msg.inspect}\\n"
#     end
#   end
#
#   class << self
#     def logger
#       @logger ||= Logger.new(STDOUT).tap do |logger|
#         logger.formatter = LogFormatter.new
#       end
#     end
#
#     def logger=(logger)
#       @logger = logger
#     end
#   end
#
#   module Logging
#     ANSI = {
#       :red    => 31,
#       :green  => 32,
#       :yellow => 33,
#       :cyan   => 36
#     }
#
#     def log(*args)
#       logger.info(*args)
#       STDOUT.flush
#     end
#
#     def logger
#       Travis.logger
#     end
#
#     def notice(message)
#       log colorize(:yellow, message)
#     end
#
#     def colorize(color, text)
#       "\\e[#{ANSI[color]}m#{text}\\e[0m"
#     end
#   end
# end
