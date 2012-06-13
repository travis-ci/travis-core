module Travis
  module Notification
    module Publisher
      class Log
        def publish(event)
          level = event.key?(:exception) ? :warn : :info
          log(level, event.delete(:msg))
          event.each do |key, value|
            log(level, "  #{key}: #{value}")
          end
        end

        def log(level, msg)
          Travis.logger.send(level, msg)
        end
      end
    end
  end
end
