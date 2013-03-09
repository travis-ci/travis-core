require 'travis/support/instrumentation'

module Travis
  module Addons
    module Pusher

      # Notifies registered clients about various state changes through Pusher.
      class Task < Travis::Task

        def self.chunk_size
          9 * 1024 + 100
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
              # TODO: the second argument in meter can be removed when we're sure that apps
              #       using this have newest travis-support version
              Travis::Instrumentation.meter('travis.addons.pusher.task.messages', {})

              begin
                Travis.pusher[channel].trigger(event, part)
              rescue ::Pusher::Error => e
                Travis.logger.error("[addons:pusher] Could not send event due to Pusher::Error: #{e.message}, event=#{event}, payload: #{part.inspect}")
                raise
              end
            end
          end

          def parts(payload)
            if client_event == 'job:log' && payload[:_log].present?
              # split payload into 9kB chunks, the limit is 10 for entire request
              # body, 1kB should be enough for headers
              log = payload[:_log]
              chunkifier = Chunkifier.new(log, chunk_size, :json => true)

              if chunkifier.length > 1
                # This should never happen when we update travis-worker to split log parts
                # bigger than 9kB.
                Travis.logger.warn("[addons:pusher] The log part from worker was bigger than 9kB (#{log.to_json.length}B), payload: #{payload.inspect}")
              end

              chunkifier.each_with_index.map do |part, i|
                new_payload = payload.dup.merge(:_log => part)
                new_payload[:number] = "#{new_payload[:number]}.#{i}" unless i == 0
                new_payload[:final] = new_payload[:final] && chunkifier.length - 1 == i
                new_payload
              end
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
