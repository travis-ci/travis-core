require 'pusher'

module Travis
  class Task

    # Notifies registered clients about various state changes through Pusher.
    class Pusher < Task
      include do
        attr_reader :event, :data

        def initialize(event, data)
          @event = client_event_for(event)
          @data = data
        end

        def run
          channels.each do |channel|
            trigger(channel, event, data)
          end
        end

        private

          def client_event_for(event)
            event =~ /job:.*/ ? event.gsub(/(test|configure):/, '') : event
          end

          def channels
            case event
            when 'job:log'
              ["job-#{data['id']}"]
            else
              ['common']
            end
          end

          def trigger(channel, event, data)
            Travis.pusher[channel].trigger(event, data)
          end
      end
    end
  end
end
