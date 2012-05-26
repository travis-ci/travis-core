require 'core_ext/module/include'
require 'pusher'

module Travis
  module Notifications
    module Handler

      # Notifies registered clients about various state changes through Pusher.
      class Pusher
        API_VERSION = 'v1'

        EVENTS = [/build:(started|finished)/, /job:test:(created|started|log|finished)/, /worker:.*/]

        include Logging

        include do
          def notify(event, object, *args)
            push(event, object, *args)
          end

          protected

            def push(event, object, *args)
              data  = args.last.is_a?(Hash) ? args.pop : {}
              data  = payload_for(event, object, data)
              event = client_event_for(event)

              channels_for(event, object).each do |channel|
                trigger(channel, event, data)
              end
            end

            def client_event_for(event)
              case event
              when /job:.*/
                event.gsub(/(test|configure):/, '')
              else
                event
              end
            end

            def channels_for(event, object)
              case event
              when 'job:log'
                ["job-#{object.id}"]
              else
                ['common']
              end
            end

            def trigger(channel, event, data)
              Travis.pusher[channel].trigger(event, data)
            end

            def payload_for(event, object, params = {})
              Api.data(object, :for => 'pusher', :type => type_for(event), :params => params, :version => API_VERSION)
            end

            def type_for(event)
              case event
              when /worker:/
                'worker'
              else
                event.sub('test:', '').sub(':', '/')
              end
            end
        end
      end
    end
  end
end
