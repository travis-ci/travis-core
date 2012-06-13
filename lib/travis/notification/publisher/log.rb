module Travis
  module Notification
    module Publisher
      class Log
        def publish(event)
          level = event.key?(:exception) ? :error : :info
          log(level, event.delete(:msg))

          if level == :error || Travis.logger.level == Logger::DEBUG
            event.each do |key, value|
              log(level, "  #{key}: #{value.inspect}")
            end
          end
        end

        def log(level, msg)
          Travis.logger.send(level, msg)
        end
      end
    end
  end
end
