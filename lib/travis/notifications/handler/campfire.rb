module Travis
  module Notifications
    module Handler
      class Campfire < Webhook

        class << self
          def campfire_url(config)
            "https://#{config[:subdomain]}.campfirenow.com/room/#{config[:room]}/speak.json"
          end

          def campfire_config(scheme)
            scheme =~ /(\w+):(\w+)@(\w+)/
            {
              :subdomain => $1,
              :token => $2,
              :room => $3
            }
          end

          def build_message(build)
            commit    = build.commit
            build_url = build_url(build)

            ["[travis-ci] #{build.repository.slug}##{build.number} (#{commit.branch} - #{commit.commit[0, 7]} : #{commit.author_name}): the build has #{build.passed? ? 'passed' : 'failed' }",
             "[travis-ci] Change view : #{commit.compare_url}",
             "[travis-ci] Build details : #{build_url}"].join("\n")
          end

          def build_url(build)
            host = Travis.config.host
            repo = build.repository
            "#{host}/#{repo.owner_name}/#{repo.name}/builds/#{build.id}"
          end
        end

        def notify(event, object, *args)
          send_campfire(object.campfire_channels, object) if object.send_campfire_notifications?
        rescue StandardError => e
          log_exception(e)
        end

        protected

        def send_campfire(targets, build)
          message = build_message(build)

          targets.each do |webhook|
            config = campfire_config(webhook)
            url    = campfire_url(config)

            self.class.http_client.post(url) do |req|
              req.body = { :message => { :body => message }}
              req.headers['Authorization'] = config[:token]
            end
          end
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
