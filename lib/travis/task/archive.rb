require 'faraday'
require 'cgi'

module Travis
  class Task
    # Archives a Build to a couchdb once it is finished so we can purge old
    # build data at any time.
    class Archive < Task
      include do
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def run
          touch(data) if store(data)
        end

        private

          def store(data)
            response = http.put(url_for(data), data.to_json)
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
