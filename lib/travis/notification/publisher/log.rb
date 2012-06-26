module Travis
  module Notification
    module Publisher
      class Log
        def publish(event)
          level = event.key?(:exception) ? :error : :info
          log(level, event[:payload][:msg])

          if level == :error || Travis.logger.level == ::Logger::DEBUG
            event[:payload].each do |key, value|
              next if key == :msg
              level = event.key?(:exception) ? :error : :debug
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
