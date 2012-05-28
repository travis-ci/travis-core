require 'core_ext/module/include'
require 'faraday'
require 'cgi'

module Travis
  module Notifications
    module Handler

      # Archives a Build to a couchdb once it is finished so we can purge old
      # build data at any time.
      class Archive
        API_VERSION = 'v1'

        EVENTS = 'build:finished'

        include Logging

        include do
          attr_reader :build

          def notify(event, build, *args)
            @build = build # TODO move to initializer
            archive(payload)
          end

          private

            def payload
              Api.data(build, :for => 'archive', :version => API_VERSION)
            end

            # TODO --- extract ---

            def archive(data)
              touch(data) if store(data)
            end

            def store(data)
              response = http_client.put(url_for(data), data.to_json)
              log_request(response)
              response.success?
            end

            def touch(data)
              build = Build.find_by_id(data['id'])
              build.touch(:archived_at) if build
            end

            def config
              Travis.config.archive
            end

            def url_for(data)
              "http://#{config.username}:#{CGI.escape(config.password)}@#{config.host}/builds/#{data['id']}"
            end

            def http_client
              @http_client ||= Faraday.new do |f|
                f.request :url_encoded
                f.adapter :net_http
              end
            end

            def log_request(response)
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
