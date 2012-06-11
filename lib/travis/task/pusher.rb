require 'pusher'

module Travis
  class Task

    # Notifies registered clients about various state changes through Pusher.
    class Pusher < Task
      private

        def process
          channels.each { |channel| trigger(channel, data) }
        end

        def event
          options[:event]
        end

        def client_event
          @client_event ||= (event =~ /job:.*/ ? event.gsub(/(test|configure):/, '') : event)
        end

        def channels
          case client_event
          when 'job:log'
            ["job-#{data['id']}"]
          else
            ['common']
          end
        end

        def trigger(channel, data)
          Travis.pusher[channel].trigger(client_event, data)
        end
    end
  end
end
