module Travis
  module Notifications
    module Handler

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class Campfire < Webhook
        EVENTS = /build:finished/

        class << self
          def campfire_url(config)
            "https://#{config[:subdomain]}.campfirenow.com/room/#{config[:room]}/speak.json"
          end

          def campfire_config(scheme)
            scheme =~ /(\w+):(\w+)@(\w+)/
            { :subdomain => $1, :token => $2, :room => $3 }
          end

          def build_message(build)
            commit    = build.commit
            build_url = build_url(build)

            ["[travis-ci] #{build.repository.slug}##{build.number} (#{commit.branch} - #{commit.commit[0, 7]} : #{commit.author_name}): the build has #{build.passed? ? 'passed' : 'failed' }",
             "[travis-ci] Change view : #{commit.compare_url}",
             "[travis-ci] Build details : #{build_url}"]
          end

          def build_url(build)
            host = Travis.config.host
            repo = build.repository
            "#{host}/#{repo.owner_name}/#{repo.name}/builds/#{build.id}"
          end
        end

        def notify(event, object, *args)
          send_campfire(object.campfire_rooms, object) if object.send_campfire_notifications_on_finish?
        end

        def http_client
          @http_client ||= Faraday.new(http_options) do |f|
            f.adapter :net_http
          end
        end

        def http_client=(http_client)
          @http_client = http_client
        end

        protected

          def send_campfire(targets, build)
            message = build_message(build)

            targets.each do |webhook|
              config = campfire_config(webhook)
              url    = campfire_url(config)

              http_client.basic_auth config[:token], 'X'

              message.each do |line|
                payload = MultiJson.encode({ :message => { :body => line } })

                http_client.post(url) do |req|
                  req.body = payload
                  req.headers['Content-Type']  = 'application/json'
                end
              end
            end
          end

          def http_options
            options = {}

            ssl = Travis.config.ssl
            options[:ssl] = { :ca_path => ssl.ca_path } if ssl.ca_path
            options[:ssl] = { :ca_file => ssl.ca_file } if ssl.ca_file

            options
          end

          def build_message(build)
            self.class.build_message(build)
          end

          def campfire_url(config)
            self.class.campfire_url(config)
          end

          def campfire_config(webhook)
            self.class.campfire_config(webhook)
          end
      end
    end
  end
end
