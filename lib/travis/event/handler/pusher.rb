module Travis
  module Event
    class Handler

      # Notifies registered clients about various state changes through Pusher.
      class Pusher < Handler
        # API_VERSIONS = ['v1', 'v2']
        API_VERSIONS = ['v1']

        EVENTS = [/^build:(started|finished)/, /^job:test:(created|started|log|finished)/, /^worker:(added|updated|removed)/]

        attr_reader :payloads, :channels

        def initialize(*)
          super
          @payloads = build_payloads if handle?
        end

        def handle?
          true
        end

        def handle
          payloads.each do |version, payload|
            Task.run(:pusher, payload, :event => event, :version => version)
          end
        end

        private

          def build_payloads
            API_VERSIONS.inject({}) do |payloads, version|
              payloads.merge(version => payload(version))
            end
          end

          def payload(version)
            Api.data(object, :for => 'pusher', :type => type, :params => data, :version => version)
          end

          def type
            event =~ /^worker:/ ? 'worker' : event.sub('test:', '').sub(':', '/')
          end

          Notification::Instrument::Event::Handler::Pusher.attach_to(self)
      end
    end
  end
end
