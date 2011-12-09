module Travis
  module Notifications
    module Handler
      class Campfire < Webhook

        def notify(event, object, *args)
          send_campfire(object.campfire_channels, object) if object.send_campfire_notifications?
        rescue Exception => e
          log_exception(e)
        end

        protected
        def send_campfire(targets, build)
          message = build_message(build)

          targets.each do |webhook|
            data = extract_data(webhook)
            url = extract_url(data)

            self.class.http_client.post(url) do |req|
              req.body = { :message => { :body => build }}
              req.headers['Authorization'] = data[:token]
            end
          end
        end

        def build_message(build)
          commit = build.commit
          build_url = self.build_url(build)

          ["[travis-ci] #{build.repository.slug}##{build.number} (#{commit.branch} - #{commit.commit[0, 7]} : #{commit.author_name}): the build has #{build.passed? ? 'passed' : 'failed' }",
          "[travis-ci] Change view : #{commit.compare_url}",
          "[travis-ci] Build details : #{build_url}"].join("\n")
        end

        def build_url(build)
          [Travis.config.host, build.repository.owner_name, build.repository.name, 'builds', build.id].join('/')
        end

        def extract_url(data)
          "https://#{data[:subdomain]}.campfirenow.com/room/#{data[:room]}/speak.json"
        end

        def extract_data(scheme)
          scheme =~ /(\w+):(\w+)@(\w+)/
          {
            :subdomain => $1,
            :token => $2,
            :room => $3
          }
        end

      end
    end
  end
end
