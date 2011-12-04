module Travis
  module Notifications
    class Campfire < Webhook

      protected
      def send_webhook_notifications(targets, build)
        targets.each do |webhook|
          data = extract_data(webhook)
          url = extract_url(data)

          self.class.http_client.post(url) do |req|
            req.body = { :message => { :body => build_message(build) }}
            req.headers['Authorization'] = data[:token]
          end
        end
      rescue Exception => e
        log_exception(e)
      end

      def build_message(build)
        commit = build.commit

        ["[travis-ci] #{build.repository.slug}##{build.number} (#{commit.branch} - #{commit.commit[0, 7]} : #{commit.author_name}): the build has #{build.passed? ? 'passed' : 'failed' }",
        "[travis-ci] Change view : #{commit.compare_url}",
        "[travis-ci] Build details : #{build_url}"].join("\n")
      end

      def build_url(data)
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
