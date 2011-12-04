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
          send_webhooks(object.webhooks, object) if object.send_webhook_notifications?
        end
      end
      async :notify if ENV['ENV'] != 'test'

      protected

        def send_webhooks(targets, build)
          targets.each { |target| send_webhook(target, build) }
        end

        def send_webhook(target, build)
          response = http.post(target) do |req|
            req.body = { :payload => self.class.payload_for(build).to_json }
            req.headers['Authorization'] = authorization(build)
          end
          log_request(build, response)
        end

        def log_request(build, response)
          severity, message = if response.success?
            [:info, "Successfully notified #{response.env[:url].to_s}."]
          else
            [:error, "Could not notify #{response.env[:url].to_s}. Status: #{response.status} (#{response.body.inspect})"]
          end
          send(severity, message)
        end

        def http
          self.class.http_client
        end

        def authorization(build)
          Digest::SHA2.hexdigest(build.repository.slug + build.request.token)
        end
    end
  end
end
