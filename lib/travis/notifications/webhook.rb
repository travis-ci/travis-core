require 'faraday'
require 'core_ext/module/async'

module Travis
  module Notifications
    class Webhook
      autoload :Payload, 'travis/notifications/webhook/payload'

      EVENTS = 'build:finished'

      include Logging

      class << self
        def payload_for(build)
          Payload.new(build).to_hash
        end

        def http_client
          @http_client ||= Faraday.new do |f|
            f.request :url_encoded
            f.adapter :net_http
          end
        end

        def http_client=(http_client)
          @http_client = http_client
        end
      end

      def notify(event, object, *args)
        ActiveSupport::Notifications.instrument('notify', :target => self, :args => [event, object, *args]) do
          send_webhook_notifications(object.webhooks, object) if object.send_webhook_notifications?
        end
      end
      async :notify if RUBY_PLATFORM == 'java' && ENV['RAILS_ENV'] != 'test'

      protected

        def send_webhook_notifications(targets, build)
          targets.each do |webhook|
            self.class.http_client.post(webhook) do |req|
              req.body = { :payload => self.class.payload_for(build).to_json }
              req.headers['Authorization'] = authorization(build)
            end
          end
        end

        def authorization(build)
          Digest::SHA2.hexdigest(build.repository.slug + build.request.token)
        end
    end
  end
end
