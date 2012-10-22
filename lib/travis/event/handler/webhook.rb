require 'faraday'

module Travis
  module Event
    class Handler

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class Webhook < Handler
        API_VERSION = 'v1'

        EVENTS = /build:(started|finished)/

        attr_reader :payload, :targets, :token

        def initialize(*)
          super
          if handle?
            @payload = Api.data(object, :for => 'webhook', :type => 'build/finished', :params => { :include_logs => config.include_logs? }, :version => API_VERSION)
            @targets = config.webhooks
            @token   = object.request.token
          end
        end

        def handle?
          case event
          when 'build:started'
            config.send_on_start?
          when 'build:finished'
            config.send_on_finish?
          end
        end

        def handle
          Task.run(:webhook, payload, :targets => targets, :token => token)
        end

        private

          def config
            @config ||= Config::Webhook.new(object)
          end

          Notification::Instrument::Event::Handler::Webhook.attach_to(self)
      end
    end
  end
end
