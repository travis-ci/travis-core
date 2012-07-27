module Travis
  module Event
    class Handler

      # Notifies registered clients about various state changes through Pusher.
      class Pusher < Handler
        # API_VERSIONS = ['v1', 'v2']
        API_VERSIONS = ['v1']

        EVENTS = [/^build:(started|finished)/, /^job:test:(created|started|log|finished)/, /^worker:(added|updated|removed)/]

        attr_reader :payloads

        def initialize(*)
          super
          @payloads = {}
        end

        def handle?
          true
        end

        def handle
          API_VERSIONS.each do |version|
            Task.run(:pusher, payload(version), :event => event, :version => version)
          end
        end

        def payload(version)
          payloads[version] ||= Api.data(object, :for => 'pusher', :type => type, :params => data, :version => version)
        end

        def type
          event =~ /^worker:/ ? 'worker' : event.sub('test:', '').sub(':', '/')
        end

        Notification::Instrument::Event::Handler::Pusher.attach_to(self)
      end
    end
  end
end
