module Travis
  module Notification
    module Publisher
      class Log
        def publish(event)
          # somehow publish event to Redis or whatever so we can display it on a simple web interface
          puts event.delete(:msg)
          event.each { |key, value| puts "  #{key}: #{value}" }
        end
      end
    end
  end
end
