require 'core_ext/module/include'
require 'pusher'

module Travis
  module Notifications
    module Handler

      # Notifies registered clients about various state changes through Pusher.
      class Pusher
        API_VERSION = 'v1'

        EVENTS = [/^build:(started|finished)/, /^job:test:(created|started|log|finished)/, /^worker:.*/]

        include Logging

        include do
          attr_reader :event, :build, :data

          def notify(event, build, *args)
            @event = event
            @build = build
            @data  = args.last.is_a?(Hash) ? args.pop : {}

            push(event, payload)
          end

          private

            def payload
              Api.data(build, :for => 'pusher', :type => type, :params => data, :version => API_VERSION)
            end

            def type
              event =~ /^worker:/ ? 'worker' : event.sub('test:', '').sub(':', '/')
            end

            def push(event, data)
              event = client_event_for(event)
              channels_for(event, data).each do |channel|
                trigger(channel, event, data)
              end
            end

            # TODO --- extract ---

            def client_event_for(event)
              event =~ /job:.*/ ? event.gsub(/(test|configure):/, '') : event
            end

            def channels_for(event, data)
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
end
