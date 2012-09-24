module Travis
  module Notification
    module Publisher
      class Log
        def publish(event)
          return if ignore?(event)

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

        def ignore?(event)
          event_received?(event) && sync_or_request_handler?(event)
        end

        def event_received?(event)
          event[:message].end_with?("received")
        end

        def sync_or_request_handler(event)
          msg = event[:payload][:msg]
          msg && msg !~ /Travis::Hub::Handler::(Sync|Request#authenticate)/
        end
      end
    end
  end
end
