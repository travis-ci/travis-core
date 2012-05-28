require 'core_ext/module/include'
require 'faraday'

module Travis
  module Notifications
    module Handler

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class Webhook
        API_VERSION = 'v1'

        EVENTS = /build:(started|finished)/

        include Logging

        include do
          attr_reader :event, :build

          def notify(event, build, *args)
            @event = event
            @build = build
            call(targets, payload, token) if call?
          end

          protected

            def call?
              case event
              when 'build:started'
                build.send_webhook_notifications_on_start?
              when 'build:finished'
                build.send_webhook_notifications_on_finish?
              end
            end

            def payload
              Api.data(build, :for => 'webhook', :type => 'build/finished', :version => API_VERSION)
            end

            def token
              build.request.token
            end

            def targets
              build.webhooks
            end

            # TODO --- extract ---

            def call(targets, data, token)
              targets.each { |target| send_webhook(target, data, token) }
            end

            def send_webhook(target, data, token)
              response = http.post(target) do |req|
                req.body = { :payload => data.to_json }
                req.headers['Authorization'] = authorization(data, token)
              end
              log_request(response)
            end

            def authorization(data, token)
              Digest::SHA2.hexdigest(data['repository'].values_at('owner_name', 'name').join('/') + token)
            end

            def log_request(response)
              severity, message = if response.success?
                [:info, "Successfully notified #{response.env[:url].to_s}."]
              else
                [:error, "Could not notify #{response.env[:url].to_s}. Status: #{response.status} (#{response.body.inspect})"]
              end
              send(severity, message)
            end

            def http
              @http ||= Faraday.new(http_options) do |f|
                f.request :url_encoded
                f.adapter :net_http
              end
            end

            def http_options
              options = {}
              options[:ssl] = { :ca_path => Travis.config.ssl_ca_path } if Travis.config.ssl_ca_path
              options
            end
        end
      end
    end
  end
end
