require 'pusher'

module Travis
  class Task

    # Notifies registered clients about various state changes through Pusher.
    class Pusher < Task
      def event
        options[:event]
      end

      def version
        options[:version] || 'v1'
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

      private

        def process
          channels.each { |channel| trigger(channel, data) }
        end

        def trigger(channel, data)
          prefix = version == 'v1' ? nil : version
          event = [prefix, client_event].compact.join(':')
          Travis.pusher[channel].trigger(event, data)
        end

        Notification::Instrument::Task::Pusher.attach_to(self)
    end
  end
end
