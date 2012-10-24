require 'pusher'

module Travis
  class Task

    # Notifies registered clients about various state changes through Pusher.
    class Pusher < Task
      def event
        params[:event]
      end

      def version
        params[:version] || 'v1'
      end

      def client_event
        @client_event ||= (event =~ /job:.*/ ? event.gsub(/(test|configure):/, '') : event)
      end

      def channels
        case client_event
        when 'job:log'
          ["job-#{payload[:id]}"]
        else
          ['common']
        end
      end

      private

        def process
          channels.each { |channel| trigger(channel, payload) }
        end

        def trigger(channel, payload)
          prefix = version == 'v1' ? nil : version
          event = [prefix, client_event].compact.join(':')
          Travis.pusher[channel].trigger(event, payload)
        end

        Notification::Instrument::Task::Pusher.attach_to(self)
    end
  end
end
