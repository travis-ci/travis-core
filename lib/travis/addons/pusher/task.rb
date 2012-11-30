module Travis
  module Addons
    module Pusher

      # Notifies registered clients about various state changes through Pusher.
      class Task < Travis::Task

        def self.chunk_size
          9 * 1024
        end

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
            parts(payload).each do |part|
              Travis.pusher[channel].trigger(event, part)
            end
          end

          def parts(payload)
            if client_event == 'job:log' && payload[:_log].present?
              # split payload into 9kB chunks, the limit is 10 for entire request
              # body, 1kB should be enough for headers
              log = payload[:_log]
              log.scan(/.{1,#{chunk_size}}/).map { |part| payload.dup.merge(:_log => part) }
            else
              [payload]
            end
          end

          def chunk_size
            self.class.chunk_size
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end
