require 'core_ext/module/include'
require 'faraday'
require 'cgi'

module Travis
  module Notifications
    module Handler

      # Archives a Build to a couchdb once it is finished so we can purge old
      # build data at any time.
      class Archive
        EVENTS = 'build:finished'

        include Logging

        class << self
          def payload_for(build)
            Payload.new(build).to_hash
          end
        end

        include do
          def notify(event, object, *args)
            archive(object)
          end

          protected

            def archive(build)
              build.touch(:archived_at) if store(build)
            end

            def store(build)
              response = http_client.put(url_for(build), json_for(build))
              log_request(build, response)
              response.success?
            end

            def config
              Travis.config.archive
            end

            def url_for(build)
              "http://#{config.username}:#{CGI.escape(config.password)}@#{config.host}/builds/#{build.id}"
            end

            def json_for(build)
              Api::Json::Archive::Build.new(build).data.to_json
            end

            def http_client
              @http_client ||= Faraday.new do |f|
                f.request :url_encoded
                f.adapter :net_http
              end
            end

            def log_request(build, response)
              severity, message = if response.success?
                [:info, "Successfully archived #{response.env[:url].to_s}."]
              else
                [:error, "Could not archive to #{response.env[:url].to_s}. Status: #{response.status} (#{response.body.inspect})"]
              end
              send(severity, message)
            end
        end
      end
    end
  end
end
